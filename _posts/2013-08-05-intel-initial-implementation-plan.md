---
layout: post
title: Intel - Plan for week
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

This week I'm looking at the detailed execution (in terms of how would it actually be implemented) 
of items that, in my view, are currently more well defined (please correct me if I'm wrong):

  * initialization of analysis extension (using MPI communicator)
  * analysis specification (the task wrapper we've discussed that encapsulates 
    h5query+script+tid+out_dataset)
  * MPI-based coordination (per-ION workers)
  * per-ION H5Q* and H5V* objects/routines

Things that need more refinement:

  * query-only tasks (how do we expose per-ION h5view objects to a client?)
  * sorting or layout change
  * input decomposition primitives
  * analysis script interface, i.e. what is the user iterating on, from within the script?
