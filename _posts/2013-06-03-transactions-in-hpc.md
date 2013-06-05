---
layout: post
title: TXN - Transactions in HPC
category: labnotebook
tags:
  - txn
  - hpc
  - slides
---

% Transactional HPC Storage
% Ivo Jimenez
% June 06, 2013

## tl;dr

  - transactional **capabilities** of exa-scale storage

  - transactional **requirements** of HPC applications

\note{

  - these two are fundamental for our project and aren't clear

  - at this point we know what we don't know, which is very useful IMO
}

# Transactional HPC Storage

## problem

  - one of the main motivations for having 2PC:

      - a node may not be ready to terminate a transaction.

  - do we need strongly consistent aborts? We might not, but we don't certainly know... yet.

  - less-than-serializable alternatives have been proposed recently.

  - how do we pick?

\note{
 - i.e. we want to reliably handle aborts.

 - For example, if a transaction has read a value of a data item that is updated by another 
   transaction that has not yet committed, the associated scheduler may not want to commit the 
   former.

 - many other reasons for abort: do we have them in practice in HPC transactional systems. The 
   problem is that there hasn't been transactional HPC before. FF is an experiment/proposal/POC

 - there has been uncountable objections to 2PC, yet Google and others uses it.

 - but we might not need this kind of strict abort capabilities

 - some weaker alternatives go from read-only transactions, to HATs, to eventual consistency (some 
   with OOM less overhead than 2PC)
}

## approaches

 1. systems perspective

 2. application requirements perspective

\note{
We're given IOD: what can we do with it? how would it be used by applications? planned demos are not 
comprehensive (restricted to HDF5, etc.)

after spending most of the quarter reading (a lot), I think we can frame the discussion in two axis
}

# systems perspective

## cannonical transactional architecture

![][whole]

\note{
- basic building block at every node LTM LRM
- many (40 years) of research/development.
}

## basic building block: LTM/LRM

- basic building block at every node:
    - local **transaction** manager (LTM)
    - local **recovery** manager (LRM)

- many (40 years) of research/development.

- many, many alternatives

\note{
  - start from the ground-up

  - examples:

      - a TM that uses conservative TO, guarantees a global timestamp ordering, which in turns 
        allows only serializable bernsteinconcurrency1987 schedules to run. The overhead of such an 
        approach is very high and usually systems allow different timestamps to interleave their 
        operations, which in turn allows transactions to be aborted (and thus provide weaker 
        isolation guarantees)

      - a segment-based LRM works better for multi-key transactions, whereas a page-based that uses 
        flush/no-steal can't guarantee that clients read their own writes searsstasis2010
}

## problem

  - hard to develop a generic transactional system (an TM/RM-agnostic manager)

  - **main issue**: key design decisions influenced by:

      - workload
      - system context
      - storage

  - examples:

      - hyder: nvram
      - spanner: atomic clocks
      - sinfonia: workload as mini-transactions
      - calvin: cloud middleware
      - zookeeper: 100:1 read/write ratio

\note{
there's actually thesis on this Stasis 2010, advised by David Brewer.
}

## our assumption "space"

what can we assume at the core of our system?

 - POSIX "transactions".

 - per-record locking (eg. key-value stores).

 - ADIOS/PLFS.

 - **object-based transactional API (IOD)**

\note{
- given the above discussion on LTM/LRM:

    - can we view exa-scale storage nodes as LTM/LRM ?

    - what type of transactional features are enabled by such a LTM/LRM

- not sure about consistency guarantees of ADIOS.

- Six degree paper that talks about the access patterns but that is from the point of view of a 
  single application

}

# application requirements

## isolation levels

what isolation level(s) does my application need?

  - dirty reads
  - (non-) repeatable read
  - phantom reads

alternatives:

  - 2PC [@gray_notes_1978] and variants [@al-houmaily_atomic_2010]
  - independent (a.k.a. deterministic) transactions [@cowling_granola_2012 ; @thomson_calvin_2012]
  - HATs [@bailis_hat_2013-1 ; @bailis_non-blocking_2013]

\note{
 In terms of read-phenomena:

  A dirty read occurs when a transaction is allowed to read data from a row that has been modified 
  by another running transaction and not yet committed.

  A non-repeatable read occurs, when during the course of a transaction, a row is retrieved twice 
  and the values within the row differ between reads.

  A phantom read occurs when, in the course of a transaction, two identical queries are executed, 
  and the collection of rows returned by the second query is different from the first.
}

## workload characteristics

what is my workload doing in terms of:

  - single vs. multi-object access
  - read/write ratio
  - degree of contention

multi-level isolation?

  - system can operate under different modes
  - provide APIs to let the application decide

\note{
  - what if we end up having all sorts of requirements?

  - let the app decide and create hooks to let the application determine what happens when conflicts 
    arise

  - architecturally similar to Stasis searsstasis2010
}

## our assumption space

 - PLFS-like workloads (N:1, N:N, N:M)

 - workflow-like workloads (eg. LDRD)

 - others

\note{
- not sure about consistency guarantees of ADIOS.

- Six degree paper that talks about the access patterns but that is from the point of view of a 
  single application

- what about workflows?

- don't know what LDRD stands for
}

# what should we do then?

## systems perspective

  - analyze the systems/architectural consequences of having IOD:

     - embed IOD nodes (IONs) in the transactional system architecture

     - what's missing?

     - what subsystems should we implement?

  - if we change/add/remove from current FF design:

     - what do we enable/miss?

     - what are the trade-offs?

\note{
for example, LRM is not needed to achieve high TPSs (concurrency) but we might want to have it for 
recovery (more on this later)

questions are w.r.t. traditional transactional systems
}

## more concrete

 - mock the FF IOD API using redis/leveldb/sqlite

 - the idea is to be API-compatible with IOD

 - we can then reimplement the IOD API on Ceph

 - coordination: FF-like LTM, it boils down to **TID assignment**.

\note{
how does this boils down to TID assignment? because IOD guarantees execution in TID ordering. So, 
from this point of view:

    - 2PC guarantees strict 'online' TID

    - deterministic transactions assign all TIDs 'up-front'

    - HAT assign it on an "as-needed" basis

    - Thus, TID management equals isolation-levels

challenges:

 - how do we simulate the asynchronous API. Do we need to?

 - IOD runs in fast fabric

 - what's the roll of MPI I/O collectives? In our previous discussion, we didn't talk about the roll 
   of client caches
}

## applications requirements

  - pick 2-3 workloads from [PIO][pio1] [benchmarks][pio2]
  - plus 1-2 from [OLTPBench][oltpbench] (TPC-C and YCSB)
  - implement them on our framework (IOD API)
  - implement:
      - 2PC
      - granola
      - HAT
  - compare in terms of:
      - application development
      - performance (terms of traditional metrics)

\note{
metrics: TPS, contention index, percentage of distributed transactions

other alternatives:

      - take fs-test and extend it to handle IOD workloads

      - use fs-test as our testing framework (so it can be reused later)
 }

## later

  - based on the above, evaluate:

      - the effectiveness of having multi-purpose storage capabilities (distinct modes)

      - take into account replication

      - what about recovery?

\note{
given that we have transactions now, can we replace the current global checkpoints with db-like 
recovery mechanisms (i.e. replaying/undoing based on the log)?
}

# questions/comments?

## References

[pio1]: http://www.mcs.anl.gov/research/projects/pio-benchmark/
[pio2]: http://www.cs.dartmouth.edu/pario/examples.html
[oltpbench]: http://oltpbenchmark.com/
[lrm]: _posts/images/2013-06-03-transactions-lrm.png
[whole]: _posts/images/2013-06-03-transactions-whole.png
