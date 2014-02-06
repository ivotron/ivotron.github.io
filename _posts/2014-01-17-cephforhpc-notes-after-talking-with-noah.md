---
layout: post
title: Notes after talking to Noah about thesis topic (Ceph for HPC)
category: labnotebook
tags:
  - cephforhpc
  - meeting-notes
---

Ideas that came to my mind after talking to Noah this morning 
regarding object-storage in HPC:

  * We might handle asynchronous coordination by leaving the delegates 
    continue **but** having the leaders coordinate synchronously (but 
    asynchronously from the delegates). In order to achieve this we 
    can have a synchronization thread on each node that handles the 
    syncs. If a node fails, the "main" thread (the one doing the 
    actual work) won't be able to do the next checkpoint.

  * a workload that intends to measure async i/o should take into 
    whether an app synchronizes with other for app-specific issues 
    (i.e. not I/O stuff). This can be parametrized by having:

      * max. num. of nodes that synchronize in-between checkpoints.
      * statistical distribution on how often they synchronize
      * statistical distribution on how which nodes synchronize among 
        themselves

  * a workload should also take into account that not all the nodes 
    will have stuff to write between checkpoints. Eg. from 1024 nodes, 
    at iteration 100, only half (or a third, or etc..) might actually 
    need to write.
