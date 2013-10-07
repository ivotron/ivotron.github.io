---
layout: post
title: A Framework for Exascale Analysis Shipping
category: labnotebook
tags:
  - srl
  - hdf5
  - ff
  - slides
---

# Exascale Computing

  * end of decade
  * millions of processors
  * billions of processes
  * **storage is a major bottleneck**

# Exascale Architecture

![][exa-arch]

# Exascale Stack

Current:

       apps
       --------------
       hdf/netcdf/etc
       --------------
       middleware (ADIOS, PLFS, MPI-IO, etc)
       --------------
       POSIX

<!--
  * not only middleware but HW too (SSDs)
  * metadata management
  * data placement
  * preprocessing of data (prepare to analysis efficiently)
  * I/O forwarding
  * asynchronous execution
  -->

Exascale:

       apps
       --------------
       hdf/netcdf/etc
       --------------
       exascale API

<!--
  * exa-scale merges the hw/middleware/posix layers
  * by proposing API
  * current efforts (to the best of our knowledge) Exascale IO Initiative and FF
  * **to-do**.
  -->

# Exascale Stack Features

  * transactions
  * asynchronous
  * I/O staging
  * object-based

# Staging (I/O nodes)

  * I/O nodes in compute cluster side
  * capability of executing code

![][exa-arch]

# Object-based features

  * layout
  * placement
  * format
  * transformation

![][exa-layout]

# Analysis Applications

 1. decompose input in blocks
 2. assign blocks to nodes
 3. **apply algorithm on each block**
 4. combine/merge/reduce/etc.
 5. write output

<!--
  * user cares about 3 and wants to bother as less as possible about specifics of 1-2,4-5
  * main difference is the focus on data-intensive tasks rather than compute-intensive ones (which 
    are already running in the compute nodes)
  * we don't consider workflows... yet
  * the assignment of blocks to nodes creates a neighborhood
  * applications need to be aware of these
  * communication among them follow patterns (point-to-point, nearest neighbors, etc.)
  * it's a generalization of Map/Reduce (which corresponds to all-to-all)
  -->

# Analysis Applications

 1. **decompose input in blocks**
 2. assign blocks to nodes
 3. apply algorithm on each block
 4. combine/merge/reduce/etc.
 5. **write output**

<!--
  * we are storage, so we care about these
  * richer API should make these faster/easier to implement
  * so, what are the new possibilities?
  -->

# New possibilities

  * smarter execution planning
  * compare among distinct alternatives
  * as less data movement as possible
  * active storage (dynamic user-defined code execution)

<!--
  * Analysis execution on top of exascale API:
  -->

# Our Initial Efforts

  * in the context of fast forward project
  * early prototype
  * analysis daemon running on I/O nodes (IONs)
  * receives/plans/executes analysis tasks

<!--
    * built on top of IOD (assuming)
  -->

# Architecture

![][analysis-layers]

# High-level Flow

 1. scientist ships analysis code

 2. two-phase execution:

    1. retrieve information of referenced objects
    2. optimize analysis
    3. execute

# User API

user provides:

  * name of objects to be accessed
  * script to be executed in parallel

<!--
  * I wanted to begin with something simple first
  * I think this is a good start point
  * this simulates a declarative interface (at least for basic means)
  -->

# User API

~~~ {#usage .cpp .numberLines}
H5ASinit(IOD_HANDLE); // plug to running IOD

H5AnalysisTask task = {

  .datasets = "/G1/D1, /G1/G2/G3/D2, ...",

  .script =
    "import h5py"
    "import scipy.spatial"
    ""
    "def KDTree(distance_metric='Euclidean'):"
    "   if distance_metric == 'Euclidean':"
    "   ... "
};

ret = H5ASexecute(&task);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<!--
  * non-referenced objects can be opened but won't be optimized
  * optimize on-the-fly
  -->

# User's Analysis Context

within python's environment:

  * `iod_comm`. references MPI comm
  * `local_shards`. local shards for each dataset

# Example:

~~~ {.python .numberLines}
f = h5py.File('eff_file.h5')

ds = f['/G1/D1']

for s in local_shards['/G1/D1']:
   # do something with shard
   res = user_defined_process(ds[s])

   # communicate result with other(s)
   iod_comm.send(res, dest=3, tag=15)

f.close()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<!--
  * line 5 above returns the list of `slice` objects (numpy-ish thing) that correspond to `D1`.
  * in other words, the shards local to the ION
  * important stuff to note is the usage of `local_shards` and `iod_comm`.
  -->

# Execution

  1. master ION requests the layout of referenced datasets
  2. create and populate per-ION `local_shards` dictionary
  3. communicate `local_shards` to other IONs
  4. execute script on each

<!--
  * I assume that HDF5 is using IOD "properly", i.e. no need to trigger global communication for 
    doing accessing hyperslabs
  -->

# Status

  * in the process of running on latest FF demo (Q5)

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

[exa-arch]: {{ site.url }}/images/labnotebook/2013-10-22-exa-arch.png
[exa-layout]: {{ site.url }}/images/labnotebook/2013-10-22-exa-layout.png
[analysis-layers]: {{ site.url }}/images/labnotebook/2013-10-22-analysis-layers.png
