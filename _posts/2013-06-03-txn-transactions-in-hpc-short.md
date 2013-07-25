---
layout: post
title: TXN - Transactions in HPC (short)
category: labnotebook
tags:
  - txn
  - hpc
  - slides
---

% Transactional HPC Storage

# problem

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

# questions

  - analyze the consequences of having IOD as the local transaction manager (LTM):

     - embed IOD nodes (IONs) in the traditional transactional system architecture

     - what's missing?

     - what subsystems should we implement?

  - if we change/add/remove from current FF design:

     - what do we enable/miss?

     - what are the trade-offs?

# actionable items

  - mock the FF IOD API using redis/leveldb/sqlite

  - the idea is to be API-compatible with IOD

  - we can then reimplement the IOD API on Ceph

  - coordination: FF-like LTM, it boils down to **TID assignment**.

# workloads

  - pick 2-3 workloads from [PIO][pio1] [benchmarks][pio2] (IOR, fs_test, ).

  - plus 1-2 from [OLTPBench][oltpbench] (TPC-C and YCSB).

  - implement them on our framework (IOD API).

  - coordination:

      - 2PC [@al-houmaily_atomic_2010]
      - granola [@cowling_granola_2012]
      - HAT [@bailis_non-blocking_2013]

  - compare in terms of:

      - **application requirements**. pay attention to the isolation/consistency requirements while 
        porting HPC code.
      - **performance**. w.r.t. traditional metrics: TPS, contention index, percentage of 
        distributed transactions.

# references

[pio1]: http://www.mcs.anl.gov/research/projects/pio-benchmark/
[pio2]: http://www.cs.dartmouth.edu/pario/examples.html
[oltpbench]: http://oltpbenchmark.com/
[lrm]: _posts/images/2013-06-03-transactions-lrm.png
[whole]: _posts/images/2013-06-03-transactions-whole.png
