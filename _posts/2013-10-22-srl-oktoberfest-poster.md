---
layout: post
title: 'A Framework for Exascale Analysis Shipping'
category: labnotebook
author:
  - names: Ivo Jimenez
tags:
  - srl
  - hdf5
  - ff
  - slides
classoption: landscape
template: a0poster
papersize: a0
columns: 3
columnsep: '100pt'
columnseprule: '0pt'
usedefaultspacing: "yes"
---

# Towards Exascale Storage and I/O

Exascale systems that are slated for the end of this decade will 
include up to a million of compute nodes running about a billion 
threads of execution. In this scenario, traditional methods that 
ameliorate I/O bottlenecks don't work anymore. Among the distinct 
architectures being explored, _I/O Staging_ proposes the designation 
of a portion of the high-end nodes to manage I/O 
[@lofstead_adaptable_2009 ; @liu_role_2012].

![ff]\ 

# The Problem

In current proposals, the stack is managed by middleware that seats 
between the application and the parallel file system 
[@lofstead_extending_2011 ; @bent_plfs_2009]. Since most of the 
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
full control of them, domain knowledge that is available at the 
application level could be used to execute storage operations 
efficiently.

# DOE Fast Forward I/O and Storage

The Fast Forward Storage I/O project 
[@intel_corporation_milestone_2012] is aimed at merging the features 
of existing middleware into a next-generation parallel file system 
stack. Applications or data format libraries interface against the I/O 
Dispatcher (IOD) interface, which semantically manages the staging 
area and interfaces directly with the distributed file system, without 
using the POSIX interface.

![iod-as-replacement]\ 


# I/O Dispatcher Interface

The interface exposes many features.

## Object-based


## Sharding and Placement

![ff]\ 

## Layout

![ff]\ 

# Exascale Analysis Execution

The analysis is now better :)

We can apply many proven techniques from other domains (big data)

![ff]\ 

## Flow

 1. User connects to IOD
 2. Ship Analysis
 3. Execute

## Execute

 1. Master receives task
 2. Plans execution based on metadata
 3. Executes best plan

# Use Case

We explain how this would look like

# Future Work


  * extend "prepare" phase to other object types:

      * consider K-V store (find ranges per-ION)
      * take into account HDF5 indexes
      * support for BLOBs

  * incorporate other features:

      * data transformation
      * prefetching
      * resharding

  * declarative interface

# References

---
include-after: |
  # Acknowledgements

  Exascale systems that are slated for the end of this decade will 
  include up to a million of compute nodes running about a billion 
  threads of execution. In this scenario, traditional methods that 
  ameliorate I/O bottlenecks don't work anymore. Among the distinct

  ----

  ![sandia]\  ![lanl]\  ![baskin]\ ![issdm]\  ![srl]\  ![hdf]\ 

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
