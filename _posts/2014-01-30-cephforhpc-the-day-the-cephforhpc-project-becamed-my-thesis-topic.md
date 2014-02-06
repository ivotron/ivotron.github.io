---
layout: post
title: They day the 'Ceph For HPC' project became my thesis topic
category: labnotebook
tags:
  - cephforhpc
  - msst14
  - experimental-plan
---

As noted in [01-29 notes][n], we now focus on the object-based aspects 
of an exascale storage stack, using Ceph,IOD and IOR as the 
experimental platform.

**Main goal**: test the transactional, object-based approach for 
distinct modes of operation.

Four modes we're testing:

 coord\io     async    sync
-----------  -------  ------
  async         1        2
  sync          3        4

Expectations:

 1. FF's assumption is that this is the fastest (for writing) since 
    there's no blocking at all. The backend manages the atomicity of 
    transactions.
 2. assumes applications have enough memory so that they can absorb 
    i/o locally. Will eventually saturate compute nodes up to the 
    point where this becomes as slow as 4.
 3. can prove that synchronous coordination (eg. d2t) can keep up with 
    an asynchronous backend
 4. possibly the slowest mode

# Concrete experimental plan

Setup:

  * ceph-backed IOD implementation
  * 16 storage nodes (write data to disk, log to ssd)
  * 1 monitor node
  * 4 client nodes x 4 cores per node = 16 clients

Parameters:

  1. transfer size (MB) = 1, 2, 4, 8, 16... 1024g
  2. clients = 1,2,4,8,16
  3. transactions = on/off

Setting #3 above measures the cost of handling transaction metadata in 
the backend and currently corresponds to Ceph's snapshot overhead. 
This **currently** only makes sense for when I/O is synchronous, i.e. 
2 and 4, due the usage of snapshots. If we change this so that our 
  ceph-based IOD implementation manages transaction metadata this will 
  change for 'backend' vs 'frontend' management.

[n]: {% post_url 2014-01-29-cephforhpc-the-day-txn-project-died %}
