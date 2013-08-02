---
layout: post
title: Intel - Generalizing Analysis Shipping Feature
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

Analytical tasks can be generalized as directed acyclic graphs (DAG), which are executed on IOD. We 
encapsulate the discussion of the Analysis Shipping feature around this framework. Doing so allows 
this capability to be more generic since many use cases can be embodied in it (eg. from HPC[^hpc-wf] 
and other fields[^bigdata-wf]).

The following is the high-level use case we envision for the _Analysis Shipping_ feature in EFF:

 0. User has access to an IOD instance that a given application running on CNs is making use of, and 
    decides to explore the current state of the compute job.

 1. User writes an analysis task specification consisting of an analytical workflow that the system 
    has to execute.

 2. User sends analysis task so that it gets executed on IONs.

 3. An analysis monitor object gets returned[^monitor].

 4. User can consult the execution state of the analysis task, as well as explore intermediate/final 
    results through the returned monitor.

The above is in general what we would like to provide the user with. At this point there are several 
unknowns that depend on the capabilities provided by IOD (and our correct understanding of them), 
the assumptions made on client infrastructure, capabilities of IONs to execute user-defined code, 
among others. We will frame our questions in terms of each of the steps presented previously.

[^hpc-wf]: A good overview of existing workflow management systems is contained in 
[@ludascher_scientific_2009 ; @curcin_scientific_2008]. Kepler, Pegasus, Taverna and Triana are 
compared.

[^bigdata-wf]: Examples of analytics as DAGs are found in the fields of [Business Intelligence][bi], 
[Big Data][mr-patterns] and [Distributed Machine Learning][mlb].

[^monitor]: we should pick a better term to refer to this. In the meantime, we will use "monitor".

## The analyst context

In terms of the infrastructure that the analyst has available, we have identified two alternatives:

  1. **user wants to have IONs execute the analysis in its entirety**
  2. user has access to a cluster which can be used to run analysis tasks.

In the first scenario, user assumes that IONs are capable of handling the analysis. In the second, 
the scale of the analysis is large enough that it requires a cluster (distinct from the one running 
the main scientific computation) of its own in order to perform well.

We will assume the first scenario in the rest of this document, since this is what it's being 
planned to optionally demonstrate as part of EFF.

**Questions**:

  - This entire document assumes non-iterative workflows.

## Task specification

User will specify an analysis task as a directed acyclic graph (DAG), where sub-tasks are 
represented by nodes, and their dependencies as edges. This can be done by creating a JSON[^json] 
file containing the graph description, similarly to the way in which graphs are expressed in plain 
text formats such as [dot]. For example, to express the query:

> Apply the median function to a time-range of 10 years (3650 days), over sets of data contained in 
two adjacent days, in a given area defined by a lat,long box of (36,36) within an elevation range of 
10 meters, beginning at point (547,0,0,0).

we can have the following JSON document:

```json
{
   "ops": [
      {
         "id": 1,
         "op": "slab-extractor",
         "object": "ucar_data",
         "space": {
            "corner": [547,0,0,0],
            "space":  [3650,360,360,50]
         },
         "slab": [2,36,36,10],
         "attributes": "pressure"
      },
      {
         "id": 2,
         "op": "mean"
      },
      {
         "id": 3,
         "op": "write",
         "dimensions": [
            "time",
            "lat",
            "long",
            "elevation"
         ],
         "attributes": "pressure"
      }
   ],
   "dag": {
      "1": ["2"],
      "2": ["3"],
      "3": []
   }
}
```

And graphically shown in Figure 1.

![The DAG for the three-node example.][plan]

Note that the fact that an analysis flow is composed of three operators doesn't necessarily mean 
that it will need to be implemented in three separate rounds of pipelined subtasks (see below on 
"DAG execution section"). It depends on what the capabilities of the underlying execution engine 
are. In this particular case, IOD allows for the implementation of a smarter aggregation operator 
that encapsulates all of the above in a single operation (`iod_array_read` does the slab extraction 
on its own), something like:

```json
{
   "ops": [
      {
         "id": 1,
         "op": "slab-extractor-aggregator",
         "object": "ucar_data",
         "space": {
            "corner": [547,0,0,0],
            "space":  [3650,360,360,50]
         },
         "slab": [2,36,36,10],
         "attributes": "pressure",
         "aggregate": "mean",
      }
   ],
   "dag": {
      "1": [],
   }
}
```

[^json]: This is just a top-of-the-head alternative, ideally we would like to represent DAGs 
efficiently so we might need to use an internal representation (`H5*` object).

## DAG compilation

Since the DAGs we envision are fairly simple (they operate at the IOD API level), we currently don't 
see the need of having a compiler/optimizer that would translate them into lower level directives. 
In the future, as this feature matures, it might become a requirement to support higher-level DAGs 
that would have to be compiled/optimized into the low-level DAGs we propose (or others that we 
haven't thought of)[^hdf5-dag]. Alternatively, existing workflow management tools could be extended 
to support IOD as a new execution target, in which case the tool is the one in charge of doing the 
optimization.

Having a DAG-based framework also allows the implementation of declarative language interfaces, such 
as [AQL/AFL][aql].

[^hdf5-dag]: the proposed way of plugging EFF-extended HDF5 into the analysis shipping framework 
(see section "DAG Operators") will require translations from HDF5 to IOD in the similar way that is 
done for other parts of EFF. This could be seen as some sort of compilation.

## DAG execution

### Launching

IOD's API doesn't expose any way of launching an I/O operation on multiple IONs, i.e. user app needs 
to execute a parallel (MPI) job in order to trigger the parallel execution of an I/O task. In other 
words, IOD can't, on its own, automatically instruct the parallel access to PLFS shards for an 
specific array/blob object. This means that in order to execute an analysis task on IOD, an ION 
executing an analysis task will have to launch its own MPI job.

An MPI master/worker service running on IOD will be in charge of executing DAGs (similarly to the 
one described in [@rynge_enabling_2012]). The main flow of this executor service is, for each 
operator in a flow, the following:

 1. Retrieve the layout (and available indexes) of referenced objects.
 2. Initiate the optimal number of tasks.
 3. For each task, in parallel:

     1. Read data.
     2. Execute associated code.
     3. Generate/store results.
     4. (Optionally) wait for dependent tasks.

 4. Terminate (or execute next operator in the pipeline).

Figure 2 illustrates the above. The DAG on the top is the one used in the example in Figure 1.

![An MPI-based service for executing/coordinating the execution of a DAG.][mpi-cluster]

**Questions**

  - how many ranks does the MPI communicator that it's available at the IOD have? if it's just as 
    many as IONs, then the above diagram should only have one task per ION.

### Parallel execution (**to-do**: needs to be extended)

We want to exploit as much as possible the parallel features of IOD. In order to do so we can:

  - execute according to the layout of the HDF5 container (i.e. executing concurrently on distinct 
    groups/datasets).
  - for each of the above, execute concurrently at the IOD-object-level (distinct shards of 
    KV-stores & array/blob objects).

Number 1 is straight-forward, as it's a matter of correctly referencing the paths of the objects on 
which we want to execute a query. For 2, as per [@bent_milestone_2013-1], IOD exposes mechanisms to 
control the sharding/layout of objects.


**Questions**:

  - What happens when an `iod_array_read` call receives `iod_array_iodesc_t` that is not aligned to 
    the underlying chunking strategy? If this isn't supported, i.e. all calls have to be aligned to 
    the underlying layout, we will need to either reshuffle data on our side (in terms of the 
    diagram in Figure 2, this means we would need to add a new vertical set of tasks before we can 
    apply the mean; in other words, the storage can't be our intermediate result) or 
    re-layout/replicate the object. (**to-do**: add example illustrating why)

### DAOS shards

Since DAOS shards are only accessible through IOD, i.e. they have to be pre-fetched, we will not 
consider the case where analysis can be sent to DAOS nodes.

## DAG operators

An operator in a DAG has a piece of code associated with it. There are mainly three types of code 
that we'll consider:

![DAG operators.][dag-ops]

### Built-in

Built-in primitives allow the user to gain efficiency by using IOD-optimized operations, instead of 
providing its own. Examples of this are common aggregations (such as the one used in the example 
above): mean, average, quartiles, percentiles, count, sum, etc.

There could be also other types of operations such as MERGE (equivalent to `hdf5merge`), SPLIT, etc. 
that operate at the dataset level. Also, others that operate on BLOBS, that fit in the MapReduce 
usage patternt. We won't consider these in our discussion.

**Question**:

  - is it OK to target only array-based operators?

### User-defined code through Executor API

One of the ways in which a user can extend the built-in operations is through an Executor API that 
abstracts the input/execution/output behavior of operators in a DAG. The API allows to reference 
HDF5 objects.

**Question**:

  - What will the interface look like? Not sure how this can be abstracted. We can take a look at 
    the SciDB API for inspiration.
  - What unit of iteration do we use (chunks/items vs. array/blob/kv-pairs)?

### User-defined code through adaptation layer

Since the bast majority of code that a scientist wants to run might be already written, the ideal 
would be to support:

  1. python[^h5py], Perl, R, bash scripts.
  4. Java byte code.
  5. Native executables.

By embedding the corresponding runtime in an operator we could support any type of existing code 
that scientists already have written, provided that this code is interfacing correctly with 
IOD-specific objects. This would significantly ease the plugging of existing [workflow management 
tool][wfm] tools into the EFF stack. This has the consequence of having to allow the 
installation/execution of scientist's libraries and runtimes in IOD. This might not be optimal in 
all scenarios[^vm].

In order to support this scheme, an adaptation layer must seat between the IOD API and the user 
code. This would expose IOD in the similar way that VOL does in the case of HDF5. For example, a 
hypothetical EFF-extended `h5py` can be adapted by taking the corresponding python script and 
replicating it on each subtask.

**Questions**:

  - Is the MPI communicator that it's available at the IOD able to fork tasks.
  - given the complexity of supporting user-defined code, we should focus on the "built-in" types 
    first and leave the others as optional.

[^vm]: in the case of native executable files, we could potentially run it by forking a VM in an 
ION. This is way too expensive but it's included here to point that, at least in theory, any 
existing analysis code could potentially run on IOD ().

[^h5py]: [`h5py`][h5py-org] is a potential candidate to be extended to support the EFF HDF5 analysis 
extensions. The current version has support for parallel HDF5 (through the use of `mpi4py`).

## Intermediate/final results

At this point is not clear if the `H5V*` facilities will be enough to handle query results. One of 
the main issues is whether the user will be able to create new datasets from a view. An alternative 
is to be [**closed**][closure] in our DAG "algebra", i.e. operators take arrays/blobs/KV-pairs as 
input and generate arrays/blobs/KV-pairs, respectively. This means that, as part of the DAG, the 
user would need to specify the group/dataset where the result should be stored (or alternatively if 
the).

There's also the issue of not materializing a result, eg. when a query is issued and just pointers 
to existing data are required (in the example, the slab extractor shouldn't materialize the 
sub-arrays, but pass their values to the mean function). In this case, an alternative is to create 
new metadata of a virtual, read-only HDF5 file which contains links to the actual data.

**Questions**:

  - representation: h5view vs h5file
  - in the case when a new dataset is materialized, should we support the specification of the 
    logical/physical ordering as part of the DAG?
  - do we need to support the storage of a result in an external HDF5 container?
  - how/where do we allow the user to create/store indexes?

## Target examples

Given the bast number of use cases that can be targeted, it would be useful to narrow down a couple 
of specific examples in order to focus better the project and its deliverables. Possible ideas 
include:

  - Simple queries such as:

      - find all objects named "foo"
      - find all the elements having values > 34, and so on.

  - We can also look for more complicated ones (taken from the SciHadoop paper 
    [@buck_scihadoop_2011]):

      - Apply the median function to a time-range, over sets of data contained in two adjacent days, 
        in a given area (defined by a lat x long box) within an elevation range.
      - Regrid the pressure variable along time and latitude dimensions using units weeks and full 
        degrees, respectively. Interpolate using average.

    We can extract the querying part for these examples.

  - Look for more examples in recent published articles [@su_supporting_2012 ; @leyshock_agrios_2012 
    ; @sehrish_mrap_2010 ; @wang_scimate_2012 ; @wang_supporting_2013 ; @buck_sidr_2013]. Similarly 
    as above, we can extract the querying part from the examples.

  - Others:

      - [UV-CDAT](http://uv-cdat.llnl.gov/wiki/UseCases)
      - [SciDB use cases](http://uv-cdat.llnl.gov/wiki/UseCases)
      - [AMUSE examples](http://www.amusecode.org/doc/examples/)

**Questions**:

  - implement a more complex example involving the reshuffling/re-laying-out of data (can IOD be 
    used as a means of communicating between dependent subtasks).

# References

[mr-patterns]: http://highlyscalable.wordpress.com/2012/02/01/mapreduce-patterns/
[mlb]: http://www.mlbase.org
[h5py-org]: http://www.h5py.org/
[bi]: http://en.wikipedia.org/wiki/Business_intelligence#Business_intelligence_and_business_analytics
[wfm]: http://en.wikipedia.org/wiki/Scientific_workflow_system
[aql]: http://www.paradigm4.com/technology/aql-afl-query-languages/
[closure]: http://en.wikipedia.org/wiki/Closure_(mathematics)
[mpi-cluster]: images/labnotebook/2013-07-09-mpi-cluster.png
[plan]: images/labnotebook/2013-07-09-dag-plan.png
[dag-ops]: images/labnotebook/2013-07-09-dag-ops.png
