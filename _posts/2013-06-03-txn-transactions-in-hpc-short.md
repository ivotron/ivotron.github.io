---
layout: post
title: TXN - Transactions in HPC (short)
category: labnotebook
tags:
  - txn
  - hpc
  - slides
---

# problem

  - hard to develop a generic transactional system

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

IOD:

  - implement IOD API in Ceph
  - coordination:
      - initially: 2PC on Paxos [@gray_consensus_2006]
      - later: granola [@cowling_granola_2012] and HAT [@bailis_non-blocking_2013]
      - with an FF-like LTM, it boils down to **TID assignment**

workloads:

  - modify fs-test:
      - extend IO modes (add a new `IO_IOD` mode)
      - add new `READ_WRITE` type of test
  - [OLTPBench][oltpbench] (TPC-C and YCSB).
  - port one [Parallel I/O][pio1] [benchmarks][pio2] (IOR, AMR, ??).
  - compare in terms of:
      - **application requirements**
      - **performance**

# references

[pio1]: http://www.mcs.anl.gov/research/projects/pio-benchmark/
[pio2]: http://www.cs.dartmouth.edu/pario/examples.html
[oltpbench]: http://oltpbenchmark.com/
[lrm]: {{ site.url }}/images/labnotebook/2013-06-03-transactions-lrm.png
[whole]: {{ site.url }}/images/labnotebook/2013-06-03-transactions-whole.png
