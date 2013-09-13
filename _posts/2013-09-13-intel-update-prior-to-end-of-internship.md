---
layout: post
title: Intel - Implementation Issues/Questions
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
  - slides
---

# {{ page.title }}

What I've been doing:

  * executing local VOL calls

<!--
  - ended up just creating the client and ignoring shipping
  - although I have a branch where I have a basic shipping
  -->

  * integrating h5py

<!--
  - I had to modify it a little bit so that the appropriate FAPL is passed
  -->

  * integrating mpi4py

<!--
  - I had to find a way of providing the communicator
  -->

  * obtaining local shards for datasets

<!--
  - I had to modify it a little bit so that the appropriate FAPL is passed
  -->

  * finding example to demo

<!--
  - Haven't started the search actually ; been busy implementing "infrastructure"
  -->

# Arch

![](images/labnotebook/intel-ion.jpg)

# Arch

![](images/labnotebook/intel-ion2.jpg)

# Usage

User provides:

  * Name of objects to be accessed
  * Script to be executed at each ION

<!--
  * I wanted to begin with something simple first
  * I think this is a good start point
  -->

# Usage (in code)

~~~ {#usage .cpp .numberLines}
H5ASinit(IOD_COMM); // initializes an EFF client

H5AnalysisTask task = {

  .datasets = "/G1/D1, /G1/G2/G3/D2, ...",

  .maps = "/M1, /G1/G2/M2, ...",

  .script =
    "from time import time,ctime\n"
    "print 'Today is',ctime(time())\n",
};

// synchronous
ret = H5ASexecute(&task);

assert(ret == 0);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<!--
  * invoked from the server VOL plugin

  * being invoked from a client for testing purposes

  * user can execute anything the python interpreter can (example is meaningless; something 
    meaningful later)

  * this is robust enough:
      * can support the EFF analysis API
      * needs to be extended later to accept values (eg. `pressure == 17`)

  * alternatives:
      * optimize on-the-fly
  -->

# User's analysis context

Within python's environment:

  * `iod_comm` references MPI comm (can be used with `mpi4py`)
  * `local_shards` contains local slices (a.k.a. shards) for a given dataset.

# Example:

~~~ {.python .numberLines}
f = h5py.File('eff_file.h5')

ds = f['/G1/D1']

for s in local_shards['/G1/D1']:
   # do something with shard
   res = process_slice(ds[s])

   # communicate result with other(s)
   iod_comm.send(res, dest=3, tag=15)

f.close()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* line 5 above returns the list of `slice` objects (numpy-ish thing) that correspond to `D1`.
* in other words, the shards local to the ION

<!--
  * important stuff to note is the usage of `local_shards` and `iod_comm`
  * d
  -->

# Server initialization

  1. initialize python runtime
  2. create global variables `fapl_id` and `iod_comm`
  3. import h5py
  4. import mpi4py (without invoking `MPI_Init()`)

<!--
  * as mentioned before, I had to add a new `h5py` driver for the EFF VOL
  * I'm having some issues that I haven't identified yet
  * I'm using native VOL plugin for now
  * might be related to the fact that no actual backend is running
  -->

# Server execution

  1. master ION requests the layout of referenced datasets
  2. create and populate per-ION `local_shards` dictionary
  3. communicate `local_shards` to other IONs
  4. execute script on each ION

Main assumption:

> hyperslab selection from EFF-HDF5 uses the underlying IOD's mechanism for selecting slabs

<!--
  * I assume that HDF5 is using IOD "properly", i.e. no need to trigger global communication for 
    doing accessing hyperslabs
  -->

# Status

  * No IOD, so no real layout info yet
<!--
  * mocking it for now
  * predefined sharding (same layout for every dataset)
  -->
  * `h5py` is using `Native` instead of `IOD` driver
<!--
  * need to identify if this can be fix or should wait for actual IOD implementation
  -->
  * only one dataset supported
  * python embedding using very-high level layer (VHL)
  * no `mpi4py` yet
  * every rank plans its execution (instead of master)

# To-do

  * improve layout identification
<!--
  * support more than one dataset
  * parametrize it (so that HDF5 layout routines (or IOD) can be plugged easily)
  -->
  * proper python embedding (use low-level layer)
<!--
  * python embedding is using very-high layer
  * should use "proper" embedding
  -->
  * add support for `mpi4py`
  * find illustrative example
  * write report


# Out of scope

  * obtain local shards on-the-fly instead of a-priori?
  * what about writes?
  * create `H5I` stuff for analysis data structures (`H5AnalysisTask`, `H5LocalShards`)
  * make analysis client be part of the server-side VOL process instead
  * add support for `H5V*` and `H5Q*` routines defined defined in EFF docs
  * fix issues with `IOD` driver
  * add support for `H5FF` wrappers in h5py
<!--
   - in order to make use of async features and other structures such as Map, dynamic structures, 
     event queues, etc
  -->
  * plan execution at master rank and broadcast locality information
<!--
   - invoke `get_local_info` from master instead of every rank. This requires to invoke it in `rank 
     == 0` and broadcast the info to all the other ranks.
  -->
  * add support for KV ranges
<!--
   - in short, when `get_local_info` is invoked, we obtain the local ranges for every rank
  -->
