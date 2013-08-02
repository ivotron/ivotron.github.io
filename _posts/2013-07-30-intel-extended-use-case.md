---
layout: post
title: Intel - FF Analysis Shipping
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

This is a follow-up document to the [Analysis Shipping Basic Functionality][asbf] writeup. We 
describe the architecture, HDF5 extensions, as well as use cases that we are using to illustrate the 
analysis shipping capabilities of FF.

# Preliminaries

## Slab Extraction

In order to illustrate slab extraction, we will assume we have a two-dimensional \<lat,long\>, whose 
values contain temperature measurements (Figure 1).

![Two-dimensional array of temperature measurements][2d]

The measurements we're interested are numbered 0-9. We will refer to them later in our examples. 
Assume that the array is distributed on three nodes as exemplified by the diagram in Figure 2 
(ignore dashed lines). The diagram shows values 0-3 in node 1, 4-8 in node 2 and 9 in node 3.

![Two-dimensional array sharded among three storage nodes (ignore dashed lines)][2ds]

Now, we can define analytical tasks on this array. A very common type of operation is to divide the 
array in chunks utilizing a domain-specific criteria and process each chunk independently. This 
partitioning of an n-dimensional space is referred to as _slab extraction_ and is shown in Figure 3. 
Note how partitions (a.k.a. chunk or slab) 1 and 3 are aligned with the underlying sharding, whereas 
partition 2 isn't (spans nodes 2 and 3).

![Chunking][ch]

Along with slab extraction, the data can also be filtered by value. In our example, we could define 
a matching criteria that specifies which values should be part of the slabs, that is, which values 
from the array should be skipped and not read at all. An example of this is shown in Figure 4. 
Analysis is then applied to each slab independently. For example, obtaining the average for each 
slab would result in three new values generated.

![Chunking and filtering][chaf]

## Analysis applications

In general, analysis applications can be described as a network of operation, as we have described 
previously in [Generalizing Analysis Shipping][gral], and as shown in Figure 1. Each analysis node 
in such a graph is a parallel algorithm that has the following structure [@peterka_scalable_2011]:

```cpp
/**
 * Prior to the execution of the algorithm
 * data is decomposed and assigned to each
 * process (which this algorithm runs on)
 */
void ParallelAnalysisAlgorithm()
{
  ReceiveLocalChunks();

  ...


  LocalAlgorithm();

  ...

  CommunicateWithOthers();

  ...

  Output();

}
```

Prior to the execution of the algorithm, there's a process of data decomposition and distribution 
(assignment of subsets of the data to processes). This means that the input (usually a 
multi-dimensional array) is partitioned and each chunked is passed to each process (this is 
encapsulated in the `ReceiveDecomposedData` call). Once every process has the data it requires, the 
local algorithm is executed and, after it finishes, it communicates with other processes to 
determine further steps (send local data or receive data from other processes), computes again based 
on what has received/sent and finalizes by sending/writing output of data.

![Analysis applications (taken from [@peterka_diy_2013])][ap]

Thus, in order to fit many use cases, an analytical execution environment must be able to support 
this general mechanism. In our case, we would like to provide the user with the ability to specify 
the decomposition through querying facilities; user-defined chunk-to-process assignment; inter-node 
communication; and writing of output data.

### Communication patterns

Analysis applications can be categorized by the type of communication they use. This subsection is 
based in [@peterka_scalable_2013], slides 16-17.

  * Point-to-point
  * All neighbors
  * subset of neighbors
  * wraparound neighbors
  * etc.

As mentioned previously, instead of re-implementing existing communication algorithms, we will give 
access to the underlying MPI communicator within the analysis context, so that algorithms or 
existing analysis frameworks make use of it.

# Analysis Shipping Architecture

The following is the analysis shipping component within FastForward's architecture:

![Architecture for the FF stack, including analysis shipping components.][as]

We describe briefly each component running on IONs/SNs (the server-side VOL process).

## RPC (via Mercury)

**to-do**

## Initialization

The analysis execution library gets initialized along with the stack, giving it an MPI communicator, 
in the same way that IOD does. This is used to communicate among IONs when executing an analysis 
task and it's also made available to the analysis application (in the python environment via 
`mpi4py`; see section [Python Runtime]).

## HDF5 Analysis Extension

The extensions comprise:

  * objects and routines to ship analysis tasks
  * orchestration of analysis execution
  * python wrappers that expose data/mpi to analysis scripts

### Analysis shipping objects

The HDF5 analysis extension module defines the data structures and routines that allow the user to 
interface with the analysis shipping service (see [Analysis Specification]).

### Coordinator

The master worker coordinator is an MPI program running on IONs (or SNs) (Figure 5). For each 
analysis task, the master instructs every ION to execute a query, package the result and feed it to 
the python script.

![Master/worker coordination][mw]

The following is a high-level description of how an analysis task is executed:

 1. H5Analysis_specification gets sent to “master” ION
 2. HDF5 analysis extension executes in three phases:

    **Phase 1 - Execution setup**:

     1. Creation of output dataset.

    **Phase 2 - H5Query execution**:

     1. Send H5Query to each worker, one per ION
     2. Each node executes H5Query, triggering local VOL calls
     3. H5View objects are created on each ION

    **Phase 3 - Python script execution**:

     1. Snippet gets sent to worker along with arguments and inputs (H5View and output dataset 
        references)
     2. Each ION executes script locally
     3. Script optionally communicates with other processes
     4. Script optionally writes to the output dataset

 3. After all workers are done, master notifies the caller of termination.

### Python Runtime

The python runtime is embedded in each worker in the analysis extensions (using the python [C 
bindings][pybinds]). When the coordinator is initialized, an instance of `mpi4py` is also 
initialized, giving it the same MPI communicator.

## Analysis Server

**to-do**

# Analysis Specification

An analysis task is specified by defining an `H5Analysis_specification` object that encapsulates the 
following:

  * Query that produces analysis script's input
  * Analysis Script
  * Parameters to script
  * TID of data being queried
  * TID of newly written data
  * Output specification

We will use the two-dimensional from [Slab Extraction] section. The analysis task we will use is 
defined as follows:

> "obtain the temperature average for chunks defined by non-overlapping \<lat,long> slabs of size 
\<3x4\>, ignoring values in the lat,long ranges 100-200"

The above is illustrated in Figure 3, with the addition that we take the average for each slab. We 
will ignore the issue of sharding alignment for now (see [Next Steps] section).

## `H5Query`

> **Note**: Throughout this document, we use a declarative representation of queries in order to 
ease their exposition. This will not be supported by the EFF HDF5 analysis extensions. Instead, the 
user has to programatically create a query with routines specified in [@koziol_milestone_2013-6].

The range of temperatures used in the our case can be expressed by the following query:

```sql
FOR     '/path/to/where/dataset/is/located/'
WHERE   dataset_name = 'temperature' AND
        lat < 100 AND lat > 200
        lon < 100 AND lon > 200
```

The above retrieves the shaded strip from Figure 4 (i.e. the cells containing values 0-10).

### H5View

The result of a query is represented by `H5View` objects, which conceptually are references that 
point to the underlying objects contained in the HDF5 file. The user dereferences these in order to 
access the values of the objects. For more information on this consult [@koziol_milestone_2013-6].

In our small example, the query would result in having three `H5View` objects, one per ION. Each 
would give access to the values on each chunk ((0,1,2), (3,4,5,6) and (7,8,9)).

## Python script

As mentioned above, the result of a query is an `H5View` object [@koziol_milestone_2013-6]. These 
views are passed to the python script in the form of [SciPy][scipy] arrays.

### Slab extraction

In the example analysis app, the actual slab-extraction routine is implemented in python. There are 
[libraries][slabpy] that provide with this functionality. We will assume that this slab extraction 
mechanism also assigns slabs to ranks (by making use of the `mpi4py` package). That is, we assume 
that, after slabs have been extracted, if an algorithm needs to communicate to neighboring 
processes, it knows which ranks to talk to in order to do so. An alternative would be to have this 
chunk extraction and assignment as part of the querying mechanism (see [Next Steps] section).

### Analysis

The following script obtains the average per slab:

~~~{.python .numberLines}
# h5_view, mpi_comm, new_ds, objects are loaded by coordinator

# collectively decompose the view
my_slabs = extract_slabs(h5_view, mpi_comm, arg_1, arg_2)

# slab and new_ds are NumPy arrays (h5py datasests)
for slab in my_slabs:
   rsum = 0

   for pressure in slab[:,:]:
      rsum += pressure

   avg = rsum / slab.attrs['num_of_elements']

   new_ds[slab.attrs['center']] = avg
~~~

The script decomposes the view and assigns the chunks to all the processes involved in the analysis 
(line 4). This is an MPI collective operation that results in having `my_slabs` variable referencing 
the chunks that the local ION should take care of. The script then continues by iterating over each 
slab (line 7), calculating the average for each (lines 8-13) and writing it to the new dataset (line 
15). As mentioned in [Analysis Applications], the script might also communicate with other processes 
   or keep iterating before writing to the new dataset.

Note that the analysis coordinator (see [Coordinator]) loads the script's context, which properly 
initializes variables `h5_view`, `mpi_comm` and `new_ds`. The script can also receive arguments that 
are passed by the coordinator. In the example, `arg_1` and `arg_2` (which in turn are arguments to 
the slab extraction routine) correspond to the size of the chunk: 3 latitude and 4 longitude, 
respectively. This in general can correspond to generic input decomposition and chunk assignment. We 
treat the decomposition/assignment agnostically and leave it to the user.

## Transaction IDs

As noted earlier, two transaction identifiers are needed.

## Output specification

Specifies the path to the dataset/container being written, as well as the properties of the output 
dataset (layout).

# Use Cases

We will discuss other use cases that illustrate the querying and inter-ION communication 
capabilities of the analysis shipping feature.

## The dataset

The dataset is a subset of the [UCAR data][ucar] dataset, corresponding to a four-dimensional array 
(`[lat, lon, time, elevation]`) containing pressure measurements. We assume that the data is 
organized in a single file, having one group per year, eg. `/UCAR/2000/pressure` for the 
measurements corresponding to 2000, `/UCAR/2001/pressure` for those corresponding to 2001 and so 
on.

## Case 1: Basic querying

This case shows the basic querying capabilities. It also exemplifies the ability of shipping without 
specifying an analysis script.

> "Find all locations where pressure exceed 17 for year 2010"

```sql
FOR     '/UCAR/2010/'
WHERE   dataset_name = 'pressure' AND
        pressure > 17
```

As noted above, the analysis script is optional, thus the analysis execution just executes a query 
and returns the view objects.

## Case 2: Sorting

> "Sort the \<lat,lon,time,elevation\> points by pressure"

```sql
FOR      '/UCAR/2010/'
WHERE    dataset_name = 'pressure' AND
ORDER BY pressure,time,lat,lon
```

The above will either trigger reorganization of the underlying dataset object that the resulting 
`H5View` points to, or it logically re-orders it.

## Case 3: Partitioning without inter-communication

> "Find the weekly averages for every \<lat,lon\> location."

This is similar to the use used in the [Analysis] subsection.

## Case 4: Global reduction

Global average across entire dataset:

> "Get average of pressure for every year in the range 2000-2009 for the points contained in 
coordinates (36,36) with elevation of 10 meters"

This can be done by having each process obtain local sums and subsequently communicate them to rank 
0 (using the MPI communicator through `mpi4py`). The query:

```sql
FOREACH DATASET IN '/UCAR/200*/*'
WHERE   dataset_name = 'pressure' AND
        lat = 36 AND
        lon = 36 AND
        elevation = 10
```

and the script:

```python
rsum = 0

for pressure in h5view:
   rsum += pressure

if mpi4py.rank != 0:
   mpi4py.send(rank_0, rsum, slab.attrs['num_of_elements'])
else:
   mpi4py.gather(rsum,total)
   new_ds.attrs['avg'] = rsum / total
```

The above makes use of the MPI communicator to send running sums to rank 0. Note that the above is 
executed for every dataset in `/UCAR/200*`.

## Case 5: Neighborhood communication

**TO-DO**: same as global reduction but selectively communicating among ranks

# Next Steps

  * Add more detail to following sub-sections:
      * rpc
      * analysis server
      * transaction ids
      * output specification

  * how does client gets notified about termination?

  * why do we need an HDF5 iterator that allows sorting, grouping, etc.?

  * We might need to add support for specifying boundary and overlap information as part of the 
    H5Query, so that [H5View] objects can access non-local data. Declaratively, something like:

        `WITH overlap = '[3,4]'`

    This is illustrated in Figure 3 (by taking into account dashed lines). This is not for doing the 
    chunking ourselves but to provide the necessary information for slab-extraction/assignment: when 
    assigning chunks to processes, the associated module will have to decide to either assign it to 
    node 1 or 2. In either case, the h5view object will have to access data from non-local nodes.

  * Every analysis execution round runs/ships the query/script to all the IONs. In the future we 
    should have a mechanism to selectively running depending on where data is located. We have the 
    information available in order to do this. More generally, a query optimization component can be 
    developed that selects the best plan.

  * Should decomposition be part of analysis extensions?

  * `H5View`:
      * Do we need an iterator?
      * Are `H5S*` routines enough?
      * When reading the result of a query, are we expecting the user to connect individually to 
        each node and read each `H5View` independently? Do we have to aggregate views?

  * Can we code now? Possible starting points:
      * `H5AEpublic.h` API, how to make it plug-in based?
      * `H5Analysis_specification` that wraps the analytical task
      * `H5View` API

# References

[asbf]: {% post_url 2013-07-18-intel-analysis-shipping-basics %}
[as]: {{ site.url }}/images/labnotebook/2013-07-30-analysis-shipping-arch.png
[2d]: {{ site.url }}/images/labnotebook/2013-07-30-two-dimensional-array.png
[2ds]: {{ site.url }}/images/labnotebook/2013-07-30-two-dimensional-stored.png
[ch]: {{ site.url }}/images/labnotebook/2013-07-30-chunking.png
[chaf]: {{ site.url }}/images/labnotebook/2013-07-30-chunking-and-filtering.png
[mw]: {{ site.url }}/images/labnotebook/2013-07-30-analysis-mpi-cluster.png
[ap]: {{ site.url }}/images/labnotebook/2013-07-30-analysis-app.png
[slabpy]: http://psistarpsi.nfshost.com/pydoc/index.html
[pybinds]: http://docs.python.org/2/c-api/intro.html#embedding-python
[scipy]: http://h5py.org
[ucar]: http://ucar.edu
