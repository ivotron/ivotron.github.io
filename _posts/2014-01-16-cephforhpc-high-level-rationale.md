---
layout: post
title: Thesis Project's High-level Rationale (the case for object-based storage in HPC)
category: labnotebook
tags:
  - cephforhpc
  - txn
  - high-level
---

# the need of a file system

  * HPC relies on writing files for:

      * sharing output (analysis/viz use simulation output as input)
      * fault-tolerance (crash-recovery from files)

  * this won't change unless:

      * analysis/viz runs completely online and analysis/viz output 
        can be accessed directly on the compute nodes. This is 
        unfeasible because compute resources are expensive
      * there's no way of doing fault-tolerance without spitting all 
        compute output somewhere else (besides compute node's 
        memory/local-disk)

  * thus, HPC apps will still rely on file systems in the foreseeable 
    future

# the problem

  * HPC apps use POSIX (or libraries that assume POSIX, eg. MPI-IO, 
    PLFS, ADIOS, etc.)

  * POSIX has two main sources of performance issues:

      * concurrency access control schemes: locking, false-sharing, 
        etc.
      * high number of metadata operations: metadata servers get 
        bombarded/blasted with open/close/save/etc. operations

# a possible solution

  * object-based distributed systems can be the answer to the above:

      * assuming an app's input domain can be partitioned [^part], 
        each rank writes to its own objects.

      * DHT approaches such as Ceph's avoid the need of having a 
        metadata server; clients know who to contact in order to 
        write/read stuff.

[^part]: see question #1

# the challenge

  * POSIX is very rooted in HPC, need to device interfaces that:

      * are HPC-friendly

      * support legacy-code without modification (or as minimal as 
        possible)

# the approach

Define a new object-based interface amenable for HPC applications. 
This might or not correspond to IOD.

## writes

New apps:

  * access objects directly :)

Legacy code:

  * Define also a FTI-like interface that allows the registration of 
    variables
  * Each rank registers its variables and lets the API manage those 
    (i.e. it only needs to call "write"). Internally, this can be done 
    by creating a BLOB object for each rank.

## reads

new apps:

  * access objects directly :)

Legacy code:

  * when writing, additional information is written into objects ala 
    ADIOS that allow the quick "stitching" or reconstruction of the 
    whole thing (without needed global indexes like in PLFS)

in both cases it is possible to modify the layout of objects to 
increase efficiency

## fault-tolerance

Coordinate compute nodes synchronously with TXN. Then:

New apps:

   * versioning is part of the interface

Legacy code:

   * FTI-like interface with setup/execution-logic separation, which 
     takes care of transparently handling fault-tolerance.

## implementation

IOD on top of Ceph to start with.

## experiments

  * Synthetic IOD-aware benchmark.
  * or extend IOR to be "checkpointable" and add an IOD driver

baseline:

  * MPI-IO and POSIX

we show:

  * new functionality with better performance
  * backwards-compatibility with legacy-code while also, hopefully, 
    increasing performance.

# Questions

 1. are there apps where is impossible to partition the input domain? 
    How common are they? How can concurrency access coordination be 
    minimized in these scenarios? Some examples appear in 
    [@carns_case_2012]

 2. are there applications in which there is never the need to 
    synchronize among the ranks (no need for collectives? eg. 
    barriers, broadcasts, scatters, gathers, etc.?). These type of 
    apps will benefit from async coordination. But we need to identify 
    them and how common they are.

 3. an "incremental" alternative that leaves POSIX intact is to 
    combine optimistic concurrency coordination (dynamo-like, 
    compare-and-swap, etc.) with scalable metadata management (giga+, 
    dynamic sub-tree partitioning, etc.). Mike Sevilla's project is 
    related to this.
