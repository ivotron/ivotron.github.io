---
layout: post
title: ISSDM Meeting Notes - proposals and more FF questions
category: labnotebook
tags:
  - ff
  - hpc
  - transactional-storage
  - minutes
---

# New Questions

  - if BB is on CN fabric, and is using broadcast-based communication, can we have atomic broadcasts 
    and then piggy back on those messages to implement transactions? Has anybody looked at the 
    atomic broadcast overhead in MPI?

    **Answer**: MPI-3 is fault-tolerant but not at the atomic-broadcast level, that is, it only 
    allows the app to know when there’s a failure, the application doesn’t crash and the 
    communicator is still functional but it isn’t magical in the sense that it will automatically 
    replicate the state of a process in a new node and restart where it was left.

  - how is it that server-side coordination enables asynchrony? We need to re-read the IOD 
    milestone docs to try to understand this.

    **Answer**: server-side coordination means that IOD is off the fast network

  - from FF docs:

    "As IOD does not know CN ranks' process group information and function shipping server does not 
    create appropriate process group based on CN ranks’ process topology, so IOD cannot use group 
    collective communication. When the number of participators is large, the status synchronizations 
    will introduce considerable overhead and latency at IOD layer."

    it's not clear why this has to happen. Why can't the compute job just create an mpi_comm_world, 
    split it in two so that it allocates one sub-comm for the CNs and another for the IONs and use 
    atomic broadcasts on each? Where's the P2P need comming from.

    **Answer**: server-side coordination means that IOD is off the fast network

  - Noah asked about the data layout optimizations at the IOD that could be done when we take into 
    account the access patterns of different applications. We mentioned how it would be nice if 
    [fs-test](https://github.com/fs-test/fs_test) could include some configuration that would allow 
    to generate these access patterns so that we can test on our own. They currently don't have 
    anything that would be considering this.

  - Is CN process talking to any ION or just to one and then that one forwards the I/O requests to 
    the corresponding ION?

    **Answer:** both

# Proposals

## Joe: SciHadoop-like analytics at the IOD

This is very interesting from Aaron's point of view. Main difference is that latencies are much 
shorter due to the fact that IOD is on CN interconnect

## Transaction Coordination Alternatives

Initially look at 2PC variants and measure its performance on MPI. Then look at alternative, 
decentralized coordination. Also look at fault-tolerance (atomic broadcasts)

Suggestions from Aaron:

  - weight the alternatives of having IOD in the same interconnect or not. What are the trade-offs 
    that appear, in terms of coordination, when we are on/off the fast fabric.
  - fault-tolerant MPI is definitely in the future (2018 exascale timeframe), so this is something 
    that it's worth looking at.

## SDN for HPC

This is definitely interesting. Aaron would like to know more about this but w.r.t. infini-band SDN.
