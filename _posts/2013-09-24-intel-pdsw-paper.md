---
layout: post
title: Intel - PDSW paper
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
  - paper
---

# {{ page.title }}

 0. **abstract**. exa-scale storage systems will provide async and transactional features. also, 
    they now implement rich, non-posix and object-based APIs, that, among others, provide layout and 
    locality information about objects being stored. This opens to a new set of possibilities, where 
    implementing smarter analysis execution mechanisms on top is feasible without middleware of any 
    kind.

 1. **intro**. talk about general storage-related problems in HPC, exa-scale storage more 
    extensively.

 2. **motivation**.

     1. **current approaches to analysis**. talk about existing filesystem/staging/middleware combos 
        and how their approach is painful
     2. **fast forward's iod**. introduce the IOD interface, highlighting its object-oriented 
        features.
     3. **hdf5 vol architecture and the FF vol plugin**. introduce both

 3. **exa-scale analysis execution**. this section describes our approach. First we talk about the 
    rationale behind it, then describe the implementation

     1. **new posibilities with IOD's interface**. since we have now layout information, we can make 
        better informed decisions.
     2. **executing analysis**. describes the new way of executing analysis through more informed 
        planning
     3. **taking it to the scriptable level (python et. al.)**. discusses the scriptable interface, 
        in particular its python implementation

 4. **evaluation**. this will compare existing filesystem/staging/middleware combos (eg. 
    Lustre/PreData) vs. our approach.

 5. **related work**

 6. **conclusion, future work and acknowledgements**

The road to exascale computing is well underway. Exascale systems that are slated for the end of 
this decade will include up to a million of compute nodes running about a billion threads of 
execution. In this scenario, traditional methods that ameliorate I/O bottlenecks don't work anymore. 
This has prompted the exploration of distinct storage system designs and techniques in order to deal 
with the high amount of I/O load.

Among the distinct architectures being explored, _"I/O Staging"_ proposes the designation of a 
portion of the high-end nodes to manage I/O. These "I/O nodes" handle requests forwarded by the 
scientific applications, integrate a tier of solid-state devices to absorb the burst of random 
operations, and organize/re-format the data so that transfers from the staging area to the 
traditional parallel file system can be done more efficiently. Staging areas have also the 
capability of executing analysis on the fresh data that has just been produced by simulation 
applications running at the compute nodes. However, the analysis code has to be already loaded on 
the staging nodes in order for them to execute. This mechanism is hard to operate since every time 
that new analysis functionality is added, the entire cluster has to be shutdown, binaries recompiled 
and distributed, and finally rebooted. This is prohibitive in HPC scenarios where time-sensitive 
applications can't be stopped.

In this work, we present a framework for the execution of analysis code that allows the user to 
explore the content of the data, ship and execute jobs, and obtain results, all done dynamically 
without obstructing the operation of the high-end machine. In concrete, we implement a master/worker 
cluster on the staging nodes that is in charge of receiving, planing and executing analytical tasks 
on behalf of the user.

Each worker embeds the python runtime, which allows the user to ship scripts and ...

this sub-cluster and many optimizations can be done in this area. One of them is exploring the 
analysis of data

"I/O staging" is used as a way of ameliorating the I/O bottleneck. This nodes are typically 
provisioned with fast hardware that can handle the bursts of data originating from scientific codes. 
This nodes are able to execute more than just storage-related operations, thus, researchers use it 
as.

Organized as online workflows and carried out in I/O pipelines, these analysis components run 
concurrently with science simulations, often using a smaller set of nodes on the high end machine 
termed ‘staging areas’.

In this work we propose a framework for allowing users to interact dynamically with the by allowing 
them to ship

--------------------


the traditional parallel file system is referred in this contexts as long-term storage. Thus, 
staging introduces a new layer in the I/O hierarchy (see Figure ).

<!--
  figure showing the exa-scale architecture
  -->

An application offloads data operations to the staging area...

# Background


## The Fast Forward Storage Architecture


## HDF5 and the VOL plugin


# Use Case: Finding normal distribution of blocks


# Related work.

  * user-defined functions in Big Data analytics
  * Jay's I/O containers, staging, etc..
  * PLFS
  * active storage
  * etc

# Future work

  * Sandboxing
  * resource management
  * extending this to workflows

# Acknowledgments

  * Intel
