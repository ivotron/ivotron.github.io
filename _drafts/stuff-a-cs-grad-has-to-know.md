---
layout: post
title: Stuff a CS Undergrad has to know
category: blog
tags:
  - knowledge-portfolio
  - cs-education
  - cs
---

By topic:

  - OS
      - memory
          - anatomy of a program in memory (TODO: link to gustavo duarte post)
              - kernel segment
              - stack
              - heap
              - mmap
              - ...
          - the above but for multi-threading (and the difference with `fork()`)
          - virtual memory
              - swap space
              - page table
              - tlb
              - page fault
      - concurrency
          - POSIX threads (pthreads)

  - Computer Architecture
      - pipelining
          - speculation
          - branching
          - branch prediction
          - multiple units
      - multi-threading
          - simultaneous multi-threading (SMT)
          - symmetric multiprocessing (SMP)
      - CPU caches (L1, L2, ...)
          - write-through
          - write-back
          - line placement
              - fully associative
              - direct mapped
              - n-way set associative
              - eviction policies (see below)
      - virtual memory
      - user vs. kernel instructions

  - languages
      - assembler
      - c
      - c++/java/c#
      - haskell/lisp/clojure/etc
      - bash/perl/python

  - compilers

General concepts (irrespective of how they're used in many domains)

  - caching
      - cache coherence
          - snooping
          - directory-based
      - locality
          - temporal
          - spatial
      - miss/hit
      - eviction policies (a.k.a. cache algorithms)
          - LRU
          - MRU
          - ...
  - concurrency
      - race condition
      - determinism
      - critical section
      - atomicity
      - synchronization primitives
      - mutual exclusion
