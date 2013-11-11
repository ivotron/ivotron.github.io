---
layout: post
title: A Framework for Exascale Analysis Shipping
author:
  - name: "Ivo Jimenez, Carlos Maltzahn"
    affiliation: UCSC
  - name: "Jerome Soumagne, Ruth Aydt, Quincey Koziol"
    affiliation: HDF Group
  - name: "Jay Lofstead"
    affiliation: Sandia National Labs
category: labnotebook
tags:
  - srl
  - hdf5
  - ff
  - slides
# following are beamer-specific
out-type: beamer
template: 'extended'
#classoption: "notes=show"
colortheme: "dove"
fontsize: 12pt
sansfont: 'PT Sans'
monofont: 'Monaco'
sansfontscale: '1.25'
monofontsize: 'scriptsize'
simplenavigation: 'yes'
nonumberontitle: 'yes'
bullets: 'true'
---

# Evolution of Storage and I/O

![][evo1]

\note{\scriptsize{
  * overview of storage and I/O in HPC

  * POSIX limiting
}}

# Evolution of Storage and I/O

![][evo2]

\note{\scriptsize{

  * structure to one-dimensional POSIX byte array

  * allows to create multidimensional arrays

  * indexing

  * handle offsets in general
}}

# Evolution of Storage and I/O

![][evo3]

\note{\scriptsize{
  * referred to as data format middleware

  * (trans) as more I/O bottlenecks started to appear...
}}

# Evolution of Storage and I/O

![][evo4]

\note{\scriptsize{

  * people also devised middleware

  * speedup the transfer of data into the FS
}}

# Evolution of Storage and I/O

![][evo5]

\note{\scriptsize{

  * this was mainly in the form of collective operations

  * that transformed into sequential form

  * random I/O nature of HPC applications
}}

# Evolution of Storage and I/O

![][evo6]

\note{\scriptsize{
  * (intro) more recently, with the advent of Solid State technology...

  * alternative approaches have been considered

  * one of them is Staging I/O (a.k.a. burst-buffers), which leverages NVRAM and SSDs to create a new level in the I/O hierarchy

  * the main characteristic of burst-buffers is that it is placed in the same fast network where the compute nodes are, while storage is on a secondary, less expensive one (cheaper)

  * this allows the staging area to handle the burst of random I/O operations coming from the compute side. And organizes it in such a way that the transfer from the I/O nodes (as they're called) to the long-term storage is as efficient as possible

  * (trans) also, new Middleware targeting the staging area has appeared.
}}

# Evolution of Storage and I/O

![][evo7]

\note{\scriptsize{

  * (intro) new Middleware targeting the staging area has appeared.

  * also, the staging area has been extended with other I/O techniques that ameliorate the I/O bottlenecks

  * I/O forwarding

  * preprocessing of data (prepare for analysis/viz.)

  * (trans) this has been working relatively well for existing systems
}}

# Exascale

  * End of decade
  * Millions of processors
  * Billions of processes
  * Storage is a major bottleneck (again)

\note{\scriptsize{
  * (intro) as we move towards exascale, where we'll have ...

  * these existing solutions collapse. Even at current petascales they break.

  * (trans) the main problem is that they keep finding workarounds to fundamental problems in the I/O stack.
}}

<!--
# The problems

  * Multi-petabyte datasets
  * Metadata performance
  * Jitter
  * Fault-tolerance

\note{\tiny{
  * (intro) is that they keep finding workarounds to fundamental problems in the I/O stack.

  * the size of the computation increases, that the data and complexity of the data models becomes really hard to manage

  * metadata management has been a bottleneck and current solutions won't scale. In general any locking-based mechanisms won't work

  * many sources of noise such at the compute node have implications that go all the way down to storage

  * these projected systems are so large that failure will be the norm, so new ways of failing and recovering fast have to be found.

  * (trans) In general, the I/O stack be smarter and simpler to use
}}

-->

# The POSIX barrier

![][posix]

\note{\scriptsize{
  * one of the fundamental issues is the POSIX interface.

  * for example, metadata management has been a bottleneck and current solutions won't scale. In general any locking-based mechanism won't work

  * on the other hand, many possibilities for scaling are already provided by the file system/middleware services

  * the problem is that in order to keep the uni-dimensional semantics, a lot of domain-specific knowledge is lost by the time it gets to the storage layer

  * (trans) being very aware of all these issues that will become critical in the near-future, the DOE
}}

# DOE FastForward Storage and I/O

\note{\scriptsize{
  * called for proposals

  * accelerate the development of new-generation components needed for exa-scale computing

  * this grant was awarded a little bit more than a year ago.

  * many companies involved, as well as national Labs

  * spans many areas, one of them being the Storage and I/O component

  * (trans) in terms of software components, the FF
}}

# DOE FastForward Storage and I/O

![][ff-layers]

\note{\scriptsize{
  * fast forward came up with a replacement to hw/middleware/posix layers

  * it integrates I/O forwarding

  * staging area managment

  * and interaction with long-term storage
}}

# DOE FastForward Storage and I/O

  * Application controls the I/O stack
  * Support complex usage patterns
  * Merge/develop technology into a unified next-generation I/O Dispatcher (IOD) API:
      * Manage the staging area
      * Handle atomicity and durability of checkpoints
      * Expose non-POSIX FS services
      * Interact with long-term storage

\note{\scriptsize{
  * make storage a tool of the scientist

  * Support flexible usage patterns to enable scientists to engage with their datasets.

  * handle BB...etc

  * (trans) the analysis framework that we propose is in the context of the FastForward, so I'd like to go quickly over the main features of the IOD interface
}}

# Staging Area Management

![][bb1]

\note{\scriptsize{
}}

# Staging Area Management

![][bb2]

\note{\scriptsize{
}}

# Staging Area Management

![][bb3]

\note{\scriptsize{
}}

# Staging Area Management

![][bb4]

\note{\scriptsize{
}}

# Staging Area Management

![][bb5]

\note{\scriptsize{
}}

# Staging Area Management

![][bb6]

\note{\scriptsize{
}}

# Staging Area Management

![][bb7]

\note{\scriptsize{
}}

# Staging Area Management

![][bb8]

\note{\scriptsize{
}}

# Atomic, Durable Transactions

![][txn1]

\note{\scriptsize{
}}

# Atomic, Durable Transactions

![][txn2]

\note{\scriptsize{
}}

# Atomic, Durable Transactions

![][txn3]

\note{\scriptsize{
}}

# Atomic, Durable Transactions

![][txn4]

\note{\scriptsize{
}}

# Atomic, Durable Transactions

![][txn5]

\note{\scriptsize{
  * atomic and durable
}}

# FS Services: Object-based

![][iod-objects]

\note{\scriptsize{
}}

# FS Services: Object Layout

![][iod-sharding]

\note{\scriptsize{
  * (trans) what about analysis?
}}

# What about Analysis?

  * Currently:
      * Treated as a second-class citizen
      * Usually runs off-line (but slow)
      * Ideal is to run in-situ, but is hard at exascale
  * Middleware:
      * Modify data as it comes into the staging area
      * Injects analysis and visualization _awareness_ into the POSIX-formated data
  * Problems:
      * Hard to co-schedule with simulation:
      * Resource contention
      * Impossible to generate results with in-situ alone
      * Temporal analysis can be difficult

\note{\scriptsize{
  * how is visualization currently handled?

  * usually runs off-line but this has changed recently since by the time simulation gets into stable storage it is already too late

  * can be co-scheduled (tightly coupled) with simulation but this is hard since resources aren't co-scheduled appropriately

  * this introduces noise to the simulation

  * (trans) by having a new stack that has the global perception we can do couple in-situ analysis and visualization better
}}

# New Possibilities

  * Rich metadata = Smarter execution
  * Consider execution alternatives
  * Optimize for distinct objectives
  * Dynamic, user-defined code execution

\note{\scriptsize{
we can leverage all this rich centralized knowledge:

  * we know what's running at the compute nodes

  * we know what's being staged at the I/O nodes

  * we know which versions are in storage

  * we know about formats, copies, sharding

alternatives:

  * we might to balance the load among IONs

  * not overload nodes to not introduce jitter into CNs

  * Minimize data movement

  * Maximize throughput

  * Indexing

  * How many copies of an object? In which format?

I/O nodes aren't static entities, they have the power of running user-defined code
}}

# Analysis Shipping

![][analysis-arch]

\note{\scriptsize{
  * Analysis execution on top of exascale API:
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')













~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
  * the idea is to expose this trough a very friendly interface

  * we chose python because of numpy, scipy, ipython

}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')












~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'










~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'
  In [4]: j.status(j)
          job 'j' is running








~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'
  In [4]: j.status(j)
          job 'j' is running
  In [5]: j.highest_committed_transaction(j)
          highest HCT for 'j': 6






~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'
  In [4]: j.status(j)
          job 'j' is running
  In [5]: j.highest_committed_transaction(j)
          highest HCT for 'j': 6
  In [6]: t = new iod.analysis('/path/to/analysis.py')





~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'
  In [4]: j.status(j)
          job 'j' is running
  In [5]: j.highest_committed_transaction(j)
          highest HCT for 'j': 6
  In [6]: t = new iod.analysis('/path/to/analysis.py', 6)
  In [7]: iod.ship(t)
          task 't' has been queued



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# IOD Console

~~~ {#usage .python}
  In [1]: iod = connect('$IOD_ADDRESS')
  In [2]: j = iod.new_job('GTC')
  In [3]: iod.execute(j)
          enqueuing job 'j'
  In [4]: j.status(j)
          job 'j' is running
  In [5]: j.highest_committed_transaction(j)
          highest HCT for 'j': 6
  In [6]: t = new iod.analysis('/path/to/analysis.py', 6)
  In [7]: iod.ship(t)
          task 't' has been queued
  In [8]: t.status
          task 't' has started
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
}}

# User Context (Analysis API)

  * Communicator among I/O nodes to allow:
      * User-defined process topology
      * Handle unalignment
      * Handle "ghost" regions between neighbors
  * Metadata about referenced objects:
      * Sharding
      * Format
      * Multiple copies
      * Placement

\note{\scriptsize{
  * simple API to python scripts:

  * within python's environment:

  * user can create domain-specific neighborhood
}}

# Example:

~~~ {.python}
def execute_analysis():

  ds = h5file['/group1/dataset1']

  for s in local_shards[ds]:
    res = user_defined_shard_management(s)

    # communicate with neighborhood
    iod_comm.send(res, neighbors(s))

    # write output, in sharding-optimal way
    new_ds = container['/group2/newdataset']
    new_ds.set_layout(get_layout())

    # coordinating with neighbors to write
    iod_comm.receive(value, coord, neighbors(s))
    new_ds[coord] = value

def user_defined_shard_management(shard):
  # possible user-defined handling of shards:
  #   * deal with unaligned shards
  #   * handle "ghost" regions
  #   * create shard-to-process assignment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\note{\scriptsize{
  * we chose python because of numpy, scipy, ipython
}}

# Status and Future Work

  * Current:
      * Extensions on FastForward's prototype
      * Implemented data-movement optimization
      * Finishing experimental setup
  * Future:
      * Modularize optimization phase
      * Incorporate other features of IOD
      * Add declarative interface
      * Plug to existing workflow managers

\note{\scriptsize{
  * in the process of running on latest FF demo (Q5). We will submit 
    it shortly

  * currently, our optimization phase is very ad-hoc. We want to take 
    advantage of the DB literature and make optimization modular and 
    feature-independent.

other types of objects:

  * Consider K-V store (find ranges per-ION)

  * Take into account indexes

  * Support for BLOBs

other features:

  * Data transformation

  * Prefetching
}}

# Thanks!

\note{\scriptsize{
}}

[evo1]: images/labnotebook/2013-10-22-evo1
[evo2]: images/labnotebook/2013-10-22-evo2
[evo3]: images/labnotebook/2013-10-22-evo3
[evo4]: images/labnotebook/2013-10-22-evo5
[evo5]: images/labnotebook/2013-10-22-evo6
[evo6]: images/labnotebook/2013-10-22-evo7
[evo7]: images/labnotebook/2013-10-22-evo8
[ff-layers]: images/labnotebook/2013-10-22-ff-layers
[posix]: images/labnotebook/2013-10-22-posix-barrier
[iod-objects]: images/labnotebook/2013-10-22-iod-objects
[iod-sharding]: images/labnotebook/2013-10-22-iod-sharding
[iod-transactions]: images/labnotebook/2013-10-22-iod-transactions
[bb1]: images/labnotebook/2013-10-22-bb1
[bb2]: images/labnotebook/2013-10-22-bb2
[bb3]: images/labnotebook/2013-10-22-bb3
[bb4]: images/labnotebook/2013-10-22-bb4
[bb5]: images/labnotebook/2013-10-22-bb5
[bb6]: images/labnotebook/2013-10-22-bb6
[bb7]: images/labnotebook/2013-10-22-bb7
[bb8]: images/labnotebook/2013-10-22-bb8
[txn1]: images/labnotebook/2013-10-22-txn1
[txn2]: images/labnotebook/2013-10-22-txn2
[txn3]: images/labnotebook/2013-10-22-txn3
[txn4]: images/labnotebook/2013-10-22-txn4
[txn5]: images/labnotebook/2013-10-22-txn5
[analysis-arch]: images/labnotebook/2013-10-22-analysis-arch
