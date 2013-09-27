---
layout: post
title: Intel - Implementation Issues/Questions
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

  * what is the `H5Vget_objs()` returning? Are this high-level objects (groups, datasets, 
    attributes, etc.) or other types of objects? If the former, why do we need separate 
    `H5Vget_attrs()` and `H5Vget_elem_regions()`.

    **A**: The documentation for H5Fget_obj_count my have the answer to this

questions:

  * identification of local shards is done on the assumption that hyperslab selection from HDF5 is 
    using the underlying IOD's mechanism for selecting slabs.

  * also, that h5py is using HDF5 hyperslabs properly

not for internship:

  * would it be better to obtain local shards on-the-fly instead of having to do it a-priori?

  * create H5I stuff for H5AnalysisTask, H5TargetInformation

  * make analysis client be part of the server-side VOL process instead

  * add support for `H5V*` and `H5Q*` routines defined defined in EFF docs (should be dropped in my 
    opinion)

  * fix issues with H5VLiod (using native for now).

  * add support for `H5FF` wrappers in h5py (in order to make use of async features and other 
    structures such as Map, dynamic structures, event queues, etc)

  * invoke `get_local_info` from master instead of every rank. This requires to invoke it in `rank 
    == 0` and broadcast the info to all the other ranks.

  * add support for KV ranges. In short, when `get_local_info` is invoked, we obtain the local 
    ranges for every rank.

for me:

  * document functions
  * define a python script that initializes the environment (instead of using sys.argv)
  * make "planing" phase robust (parametrize it based on IOD's info), by removing current 
    restrictions:
      * one dataset per task
      * one map per task
      * hard-coded limits: 10 dimensions, 5 slices per node
      * others
  * add "fake" pre-defined sharding for some datasets

--------

how to transparently work with h5py:

  1. make a global fapl_id
  2. in `files.py`, check for that value. If non-zero, assign the existing fapl

python setup (inside `H5ASinit`):

  1. call py_initialize
  2. create global variables `fapl_id` and `mpi_comm`
  3. import h5py
  4. import mpi4py but without initializing mpi (disable execution of `MPI_Init()`)

python tear-down (inside `H5ASfinalize`):

  1. call py_finalize

pseudo-code execution (for `H5ASexecute`):

  1. create `local_shards` and `local_ranges` dictionaries.
  2. populate dictionaries
  3. execute
  4. unload dictionaries

analysis context:

  1. `fapl_id` has file access property list
  2. `mpi_comm` contains reference to communicator (can be used with `mpi4py`)
  3. `local_shards` is a dictionary containing the local slices for a given dataset. For example:

     ```python
     local_slices[""]
     ```
  4. similarly (not implemented) `local_ranges` contains the local ranges for map objects
