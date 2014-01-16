---
layout: post
title: Update to plan for MSST paper
category: labnotebook
tags:
  - txn
  - msst
  - experimental-plan
---

As I try to think in next steps for our work and learn more about the 
state of the art, I feel our work has less impact that what I 
initially thought. Let me explain.

Components of checkpointing/restart frameworks include:

  * failure detection. In existing checkpoint restart frameworks this 
    is usually done using a process manager, i.e. it isn't done at the 
    MPI level. There are many articles describing MPI-level failure 
    detection.
  * fault-tolerance techniques.
      * redundancy (copy checkpoint to a neighbor)
      * ECC eg. Reed-Solomon
      * message logging
      * flush checkpoint to PFS
  * failure-recovery. One for each of the above:
      * replace node with a new one
      * reconstruct from ECC group
      * read the message log to avoid complete rollback
      * complete checkpoint roll-back
  * async I/O. SCR does this already
  * optimal checkpointing frequency. Vaidya's "forked checkpoints" 
    accomplish this.

Coordination is usually solved by "barriering" before returning from 
the `do_checkpoint_here()` call, that is, an `MPI_Barrier()` call is 
used to sync all nodes and know that a checkpoint has been written.

I feel that given all of the above, our contribution would be the 
combination of existing solutions (mpi-level fault detection, async 
checkpoints and rollback-based recovery) rather than innovating 
through a new framework. The transactional semantics are certainly 
more user-friendly, but one could argue that is the same functionality 
under different terminology. It is certainly fun enough to work on, 
but unfortunately I have to advance by April and I'd like to maximize 
the chances of publishing something by then

Now, there are a couple of things that are novel but we haven't been 
focusing on (yet). First, the object-based API. Every existing 
solution assumes POSIX and thus suffers from the same traditional 
bottleneck issues. If we assume ADIOS, IOD, RADOS (ceph), etc. we 
might get to the point where our contribution is significant. But this 
means that we actually don't have to prototype a new 
checkpointing-restart framework, instead, we can just grab an existing 
one and plug it on top of a non-posix API such as IOD. We could take 
our prototype and use that but it will be limited in terms of 
functionality.

The second contribution we could make is in the transparency of the 
framework. Every framework requires the user to implement recovery 
logic. Since we're dealing with objects, we can have the user specify 
which objects we should protect (kind of like in FTI) and specify the 
point where the program becomes "iteration-agnostic". This is 
exemplified in [this use case I wrote](). I think this approach 
achieves a right balance since minimizes modification of legacy-code 
modification.

So in summary I propose the following:

  * take TXN/FTI/SCR and adapt a benchmark (ftest/IOR/FLASH-IO/etc) to 
    use it, incorporating parameters to control fault-tolerance 
    aspects.
  * write a new IOD driver for the benchmark
  * execute experiments to compare POSIX vs. MPIIO vs. IOD

Any thoughts?
