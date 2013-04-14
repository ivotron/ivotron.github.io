---
layout: post
title: The Fast-Forward I/O and Storage Stack
category: labnotebook
tags:
  - fast-forward
  - hpc
---

# {{ page.title }}

**tl;dr**: This post gives a high-level introduction to the FastForward (FF) I/O stack, as described 
in the 2012-Q4 and 2013-Q1 milestones [@intel_scope_2012]. The [milestones documents][ff-docs] are 
organized on a per-component basis, so I thought it would be useful to have a single high-level 
intro that one could get to when trying to figure out how a particular piece fits into the whole 
picture.

## The Stack

The proposed exascale architecture is shown in the following diagram:

![Figure 1. Exascale I/O Architecture (taken from [@barton_eric_2013]).][ff-arch]

In the targeted use-case, scientists write applications on top of non-POSIX interfaces that allow 
them to transfer storage-related logic down to the system. These applications run on compute nodes 
(CN) and, during the course of an execution, results are stored temporarily in I/O nodes (ION), 
which have the capacity of handling the burst of I/O produced during peak loads [@liu_role_2012]. 
IONs hold data temporarily (depending on how often an application creates a checkpoint) and during 
that period a scientist can execute analysis on the temporary results. The I/O Dispatcher (IOD) 
executing on the IONs is in charge of structuring the random-access nature of the processes 
sequentialy optimized format (i.e. chunks) so that it gets efficiently pushed down to long-term 
storage (DAOS).

From a layered point of view, the above is generalized in the following diagram:

![Figure 2. FastForward I/O Stack (taken from [@barton_eric_2013]).][ff-stack]

The key features that should be highlighted at this point are: concurrency, asynchrony, transactions 
and function-shipping. Many scientists will run their simulations concurrently and they will be able 
to manipulate data that is "on flight", that is, they will be able to associate versions to 
checkpointed data and execute analysis on a particular version (which in turn might produce one or 
more new versions), even if that version hasn't landed in long-term storage. Since every subsystem 
has active-storage capabilities, they can execute code, as long as the input data is available to 
it. In the ideal scenario, deciding which code executes locally on the CNs, or which gets transfered 
to I/O (or DAOS) nodes should be done transparently without having the user to specify anything. 
That is, the application developer should only provide the basic information (program/versioning 
logic) and the system should be in charge of deciding what code/data gets executed/stored where (CN, 
ION or DAOS node) and when.

## The Prototype

The above is the ideal Exascale architecture. The FF project will deliver a prototype that 
implements some parts of it. Next, I describe what I understand are the components that will get 
implemented and be left out, in terms of the ideal target use-case.

The prototype stack, from a top-down point of view, has the following components:

 1. Arbitrarily Connected Graphs (ACG).
 2. HDF5 extensions.
 3. I/O Dispatcher (IOD).
 4. Distributed Application Object Storage (DAOS).
 5. Versioning Object Storage Device (VOSD).

Applications running on the compute nodes will be written in Python scripts. These applications will 
execute analysis on graph-based data (ACG). The point is to demonstrate both the HPC and BigData use 
cases of the Exascale architecture. The data structures will be stored in HDF5, for which new API 
extensions will be implemented. These new API calls will expose the transactional, asynchronous and 
function-forwarding semantics of the underlying stack.

<!--
    TODO:
The IOD will expose a PLFS [@bent_plfs_2009] interface, which will be used to structure and send 
data down to the DAOS layer, implemented in Lustre.
  -->

As mentioned before, the stack provides *non-POSIX, object-based, transactional and asynchronous 
active-storage*, meaning that POSIX is supplanted by new object interfaces that reach up to the HDF5 
layer (Application I/O in the stack diagram); transactional semantics are present all the 
everywhere, from HDF down to the VOSD layer (Storage layer); clients don't need to wait for any 
blocking operation; and analysis can be shipped and executed on I/O or DAOS nodes.

In the following, I give a high-level description of each of layer.

## ACG

This will exemplify how applications make use of the Exascale stack. For FF, support for [GraphLab 
and GraphBuilder][graphlab] will be prototyped, which are graph-processing frameworks. GraphBuilder 
is a set of MapReduce tasks that extract, normalize, partition and serialize a graph out of 
unstructured data, and writes graph-specific formats into HDFS. These files are later consumed by 
GraphLab, a vertex-centric, asynchronous execution engine that runs directly on top of HDFS (i.e. 
non-MapReduce). The following illustrates the architecture of both frameworks:

![Figure 3. GraphLab and GraphBuilder stacks (taken from 
[@willke_graphbuilderscalable_2012])][graphlab-arch]

In order to make both work on top of the exascale stack, both have to be modified. After these 
modifications are implemented, GraphBuilder will be able to write the partitioned graph in (the 
newly proposed) HDF5 files which will thus be stored in the IOD nodes (or IONs) in a 
parallel-optimized way. On the GraphLab side, HDF5-awareness will allow the library to perform at 
high speeds by benefiting from the new features (see next section). In general both frameworks will 
be modified so that calls to HDFS-based formats are replaced by the proposed HDF5 ones. This is 
referred to as the HDF Adaptation Layer or HAL and will provide, from the GraphBuilder/GraphLab 
point of view [@arnab_milestone_2012]:

  - capability for storing the newly proposed HDF5 format
  - association of network information to vertices/edges
  - shipping computation to the IONs
  - asynchronous vertex updates
  - efficient data sharing ammong CNs
  - computation over versioned datasets

## HDF5 extensions

The extensions done to HDF5 allows an application to take full advantage of the new exascale 
features. The additions comprise [@kozoil_milestone_2012-1] (Figure 4):

  1. Object-storage API based on HDF5 to support high-level data models. This exposes asynchronous, 
     transactional semantics to the application, as well as end-to-end data integrity. It will also 
     allows the usage of pointer data types, passing of hints down to the storage and support for 
     asynchronous index building, maintenance and querying.
  2. Virtual Object Layer (VOL) plugin that translates HDF5 API requests from applications to IOD 
     API calls.
  3. Function shipping from CN to IONs. This provides the application developer with the capacity of 
     sending computation down to the IONs and get back results.
  4. Analysis Shipping from CN to IONs or DAOS nodes. This is similar to 3 but instead of returning 
     the result over the network, it gets stored on the nodes and pointers to it are returned.

![Figure 4. The HDF5 stack (taken from [@chaarawi_milestone_2013]).][hdf5-stack]

In terms of the CN-ION communication model, a client/server architecture is implemented 
[@kozoil_milestone_2012]: every ION runs an IOFSL (I/O Function Shipping Layer) server 
[@ali_scalable_2009]; the IOFSL client is integrated into the HDF5 library which runs on each CN. A 
client can forward requests to any number of IONs. Every I/O operation issued by HDF5 is 
asynchronously shipped to the IOFSL server and asynchronously executed.

## IOD

The I/O dispatcher (IOD) can be simply described as the burst buffer layer to the computation nodes. 
It handles shor. Every I/O node runs a IOD client, and in turn every IOD server runs a DAOS client 
which allows it to communicate down to the long-term storage subsystem (Figure 5).

![Figure 5. The HDF5 stack (taken from [@chaarawi_milestone_2013]).][hdf5-stack]

The IOD has

It's important to note that, in the planned prototype, ION and DAOS transactional capabilities are 
"separated", that is, the fact that a transaction committed on the IOD doesn't mean that it will 
commit also on the long-term storage, and in fact might not persist if an error occurs on the ION 
after it has committed. It means however, that new results/versions can be obtained from the 
committed transaction consistently.

## DAOS

## VOSD

## References

[ff-docs]: https://wiki.hpdd.intel.com/display/PUB/Fast+Forward+Storage+and+IO+Program+Documents
[ff-stack]: {{ site.url }}/images/labnotebook/2013-04-07-ff-stack.png
[ff-arch]: {{ site.url }}/images/labnotebook/2013-04-07-ff-arch.png
[hdf5-stack]: {{ site.url }}/images/labnotebook/2013-04-07-ff-hdf5-stack.png
[graphlab]: {% post_url 2013-04-05-graphlab-and-graphbuilder %}
[graphlab-arch]: {{ site.url }}/images/blog/2013-04-05-graphlab-and-graphbuilder.png
