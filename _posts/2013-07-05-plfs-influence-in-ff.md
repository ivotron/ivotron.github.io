---
layout: post
title: Intel - PLFS impact on FF
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

I read the PLFS paper. The following questions arise:

  - VOL is implemented on top of IOD, which means that for an HDF5 dataset, an IOD array object will 
    be created. Since IOD is internally using PLFS, there will be as many shards as IONs in the 
    cluster. Thus, we can parallelize an HDF query by having a call to IOD that triggers the 
    execution of the same piece of code on every ION. This, assuming that the following assumptions 
    hold.

  - an item/chunk corresponds to a shard.

  - a shard corresponds to a subdirectory in a PLFS container.

  - read IOD API to see if it exposes some ways of controlling the concurrency of I/O operations 
    from multiple IONs, i.e. user app doesn't need to execute a parallel (mpi) app in order to 
    trigger the parallel execution of an I/O task. In other words, IOD will instruct the parallel 
    access to plfs shards for an specific request.

# Questions

  - how are PLFS subdirectories (of a logical file, a.k.a. container), distributed across the IONs? 
    This wasn't described in the docs but it looks like this will be round-robin througout the IONs. 
    If the length of writes aren't uniform (some processes write larger chunks than others) then 
    this will potentially introduce skewness.

to-do:

  - need to read the HDF5 to IOD mapping doc in order to see if my assumptions (mapping originally 
    described in IOD) are correct.

  - what about the case when the data is read from DAOS ? Can it be directly read from DAOS or does 
    it have to be loaded into BB first?
