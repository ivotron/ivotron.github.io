---
layout: post
title: Initial Thoughts on Ceph for HPC
category: labnotebook
tags:
  - ceph-for-hpc
  - planning
  - research-ideas
---

- this can be a nice thesis topic. Things to include:
    1. atomic collective (multi-client) operations
    2. burst buffer management
    3. asynchronous collectives

- optionally, multidimensional interfaces
- optionally, QoS
- we can initially explore 1 and 2. If 2 is managed in crush, we can 
  then combine it nicely with 1
