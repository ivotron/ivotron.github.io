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

<!--
comments:

Joe:

  - add slide numbers. Makes asking questions a ton easier if you can say "on slide X...l
  - first figure: fix label on storage cluster. It's under the image
  - Slide "new possibilities": third bullet should start with "is"?
  - "high-level flow" slide: use 2 bullet points for "two-phase execution". It's unclear where the 
    three items fall into the two phases.
  - maybe talk up the idea of optimizing data movement and reorganization when loading data from 
    disk into the cluster. This is a really useful feature for after the fact analytics.

Carlos:

  * Ivo's dry run; start at 9:53, ends at 10:30
  * Mention summer internship at Intel
  * Need better context for exascale: swim lanes
  * Slide numbers!
  * Pictures instead of ASCII art
      * Better stick with architecture drawing
      * "exascale API" is not that meaningful
      * You say a lot of things without illustration on that slide
  * Why transactions? Why asynchronous?
  * Architecture: explain difference of IO node network topology compared to storage nodes
  * Object-based features
      * Significance of "objects" is not clear
      * What is "IOD"?
  * Analysis applications
      * I'm lost
  * New possibilities
      * looks redundant
  * Our initial efforts
      * looks redundant
  * you start explaining everything too late
  * Architecture: finally an overview -- start with that and stick to it!
      * Check out how Eric Barton introduces all this! Needs to be much more compact
  * User API: use "system API" instead
  * Example: concept of neighborhood, needs to be determined by application
      * Need to be clearer about layering
  * Execution: 
  * Future work: Need to give a better context of your work and provide reference points of that context in your presentation

There is a lot of stuff, so this is the main challenge of the talk.

Mike:

Problem: Merge middleware + underlying API
Solution: Run dynamic code on IO nodes, control data flow dynamically, let the system place the data in the right place

Notes

* I am not familiar with the FastForward project. It might be helpful if you:
	- Explain why POSIX won't scale
	- Provide some examples of problems LANL was running into (I know they had IO nodes before but why were these failing?)
* I know nothing about the new API. You should explain:
	- Some of the additional "file system calls" that helps the user tell the system about the data
	- Explicitly compare and contrast POSIX and the new API
	- List additional user responsibilities, such as:
                - telling the system how to place data on certain compute nodes
                - grouping blocks
                - sharding data
* Add slide numbers + SRL logo

  -->

[exa-arch]: {{ site.url }}/images/labnotebook/2013-10-22-exa-arch.png
[exa-layout]: {{ site.url }}/images/labnotebook/2013-10-22-exa-layout.png
[analysis-layers]: {{ site.url }}/images/labnotebook/2013-10-22-analysis-layers.png
