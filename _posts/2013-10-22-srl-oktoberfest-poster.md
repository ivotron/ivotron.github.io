---
layout: post
title: 'A Framework for Exascale Analysis Shipping'
category: labnotebook
author:
  - names: "Ivo Jimenez and Carlos Maltzhan"
    affiliation: UCSC
  - names: "Jay Lofstead"
    affiliation: Sandia National Labs
  - names: "Jerome Soumagne, Ruth Aydt, Quincey Koziol"
    affiliation: HDF Group
tags:
  - srl
  - hdf5
  - ff
  - slides
template: a0poster
columns: 4
columnsep: '100pt'
columnseprule: '0pt'
usedefaultspacing: "yes"
titleseparator: "yes"
mainfont: "PT Sans"
monofont: "DejaVu Sans Mono"
---

# The Road to Exascale

Exascale systems that are slated for the end of this decade will 
include up to a million of compute nodes running about a billion 
threads of execution. In this scenario, traditional methods that 
ameliorate I/O bottlenecks don't work anymore. Among the distinct 
architectures being explored, _I/O Staging_ proposes the designation 
of a portion of the high-end nodes to manage I/O 
[@lofstead_adaptable_2009 ; @liu_role_2012].

![ff]\ 

**TO-DO**: add little bit more of text.

# The POSIX barrier

In current proposals, the stack is managed by middleware that seats 
between the application and the parallel file system 
[@lofstead_adaptable_2009 ; @bent_plfs_2009]. Since most of the 
applications assume a POSIX interface to storage, existing middleware 
either transparently handle the I/O operations, appearing as regular 
POSIX calls to applications; or modify the I/O API as little as 
possible in order to minimize the impact on production codes.

![posix]\ 

As we move towards the exascale goal, this way of interfacing with 
storage becomes more of an obstacle. Many features provided by 
distributed file systems are hidden by the POSIX layer and in many 
cases have to be replicated by existing middleware. If these were 
visible to the applications, and if applications were able to have 
full control of them, domain knowledge could be used to execute 
storage operations efficiently.

\ 

\ 

\ 

\ 

\ 

\ 

# Fast Forward I/O and Storage Initiative

DOE's Fast Forward Storage and I/O project 
[@intel_corporation_milestone_2012] is aimed at merging the features 
of existing middleware into a next-generation storage and I/O stack. 
Applications or data format libraries interface against the I/O 
Dispatcher (IOD) interface, which semantically manages the staging 
area and interfaces directly with the distributed file system, without 
using the POSIX interface.

![iod-as-replacement]\ 

## I/O Dispatcher Interface

The interface exposes many features: transactions, asynchronous I/O, 
object-based storage, sharding, placement and formatting. For the 
purposes of analysis, we consider the following.

### Object-based

![iod-objects]\ 

### Sharding and Placement

![iod-sharding]\ 

### Layout

![iod-layout]\ 

**TO-DO**: include more IOD features in this column:

  * transactions
  * asynchrony
  * epochs diagram maybe

\ 

\ 

\ 

\ 

# Exascale Analysis

We device a master/worker architecture running on the I/O nodes (and 
storage cluster nodes) that are in charge of receiving, planning and 
executing analysis tasks. The master or coordinator runs in one of the 
I/O nodes.

![analysis-arch]\ 

The usage flow is the following:

 1. Launch simulation on compute cluster
 2. Timestamp computed and dumped to I/O nodes
 3. Interactively explore (query) data on I/O nodes
 4. Launch analysis task at I/O nodes, possibly sending tasks to 
    execute in storage cluster
 5. Store analysis results; flush/load to/from storage into BB nodes 
    new/previous results

## Analysis Shipping

Once data is ready to be analyzed (step 3 from the usage flow), the 
user queries/analyses data by shipping a python script to the 
coordinator. We chose python due to its popularity among scientists 
and extensive bindings of bindings to scientific data formats (HDF5 in 
our case). The following is an example of an analytical session:

~~~ {#usage .bash}
 \> connect $IOD_HANDLE
 \> t = newtask ('/path/to/script.py')
 \> ship(t)
    ...
 \>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Analysis Planning and Execution

Distinct alternatives for executing the same analysis task can be 
taken, which gives room for analysis optimization. To illustrate, 
consider data-movement optimization, i.e. sending the analysis code as 
close as possible to the data in order to minimize data shuffling. In 
practice, this means we focus on identifying local shards of objects 
and execute code over them:

  1. master node requests the layout of referenced objects.
  2. create and populate per-ION `local_shards` dictionary
  3. communicate `local_shards` to other IONs
  4. execute script on each shard

## Use Case

To illustrate further, we pick an analytical example from foo. Within 
the python's environment, the user has available:

  * `iod_comm`. references MPI communicator.
  * `local_shards`. dictionary structure containing local shards for 
    each object referenced in the task specification.
  * `container`. handle to the container where the task is running on.

~~~ {.python}
def execute():

  ds = container['/G1/D1']

  for s in local_shards[ds]:
    # do something with local shard
    res = user_defined_process(ds[s])

    # communicate result with other(s)
    iod_comm.send(res, dest=3)

    # possibly write to a new dataset
    new_ds = container['/G2/D2']

    iod_comm.receive(value, dest=3)

    new_ds[s] = value

def user_defined_process(shard):
  # do something with local shard
  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<!--
[^simulation]: suffice it to say that the analysis application can get 
notified when a new timestep has been dumped into the staging area 
(I/O nodes)

[^no-workflows]: it should be noted that we don't consider workflows 
in our discussion but is something that we plan to work on.
 -->

# Conclusion and Outlook

The IOD interface allow applications to have full control of the 
storage stack, giving access to rich metadata about objects 
stored/staged in it.  This information can be retrieved and contrasted 
against the operations intended to be executed by an analytical task, 
allowing the execution engine to optimize for overall performance. 
With this foundation, we can apply many proven techniques from other 
domains (Relational Analytical Databases and Big Data systems).

# References

---
include-after: |
  # Acknowledgements

  Exascale systems that are slated for the end of this decade will 
  include up to a million of compute nodes running about a billion 
  threads of execution. In this scenario, traditional methods that 
  ameliorate I/O bottlenecks don't work anymore. Among the distinct

  ----

  \ 

  ![issdm]\   ![srl]\   ![baskin]\  ![lanl]\  ![sandia]\ <!-- ![hdf]\ -->

  [sandia]: images/logos/sandia
  [lanl]: images/logos/lanl
  [baskin]: images/logos/baskin
  [issdm]: images/logos/issdm
  [srl]: images/logos/srl
  [hdf]: images/logos/hdf
---

[posix]: images/labnotebook/2013-10-22-posix-barrier
[ff]: images/labnotebook/2013-10-22-exa-posix-highlight
[iod-as-replacement]: images/labnotebook/2013-10-22-iod-as-replacement
[iod-objects]: images/labnotebook/2013-10-22-iod-objects
[iod-sharding]: images/labnotebook/2013-10-22-iod-sharding
[iod-layout]: images/labnotebook/2013-10-22-iod-objects
[analysis-arch]: images/labnotebook/2013-10-22-analysis-arch
