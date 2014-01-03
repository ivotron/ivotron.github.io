---
layout: post
title: Ideas for Paper Experiments
author:
  - name: Ivo Jimenez
category: labnotebook
tags:
  - h5
  - hdf5
  - ff
  - paper
  - experiments
---

# stuff to check experimentally

## short-term

Since Q6 is implementing MapReduce capabilities, we can execute 
experiments that have been used before

  - MapReduce papers (Pavlo et al.)
  - SciHadoop
  - "Supporting a Light-Weight Data Management Layer over HDF5"
  - more that arise after looking at BIL's MPIIO-based experiments

## long-term

  - reduced time by not loading to compute nodes (effect of shipping)
  - read times reduced thanks to "smart" reading
  - same as above but for writing
  - re-org operations such as the ones presented in the SDS paper,

# to-do:

## short-term

  - target HPDPC
  - SSDBM as a backup
  - read BIL paper to see what experiments they have
  - read DIY's code to see how to accomplish what Tom P. mentioned 
    about direct mapping of blocks to the underlying FS

## long-term

  - download data used in the SDS paper
  - consider the following two alternatives:
    - take Peterka's DIY and plug it to IOD
    - take a messaging abstraction library and re-implement DIY by 
      abstracting MPI away. this has the benefit of being able to run 
      on many mon-MPI scenarios.
