---
layout: post
title: Intel - Meeting Notes
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

Attendees: Jerome, Ruth, Quincey

We were discussing the [document I prepared on 'a workflow engine on top of IOD']({% post_url 
2013-07-09-intel-analysis-shipping-scoping %}):

  - there is a confusion with the terms IOD and ION. IOD is the software library (the API). An ION 
    is an I/O node, where IO functions are executed
  - checkpointing and iterative workflows are different, i.e. having an iterative workflow doesn't 
    necessarily mean we have to have checkpoints being stored, although for most of the long-running 
    iterative workflows this is the case.
  - there can be only one application running at a time to one container, i.e. there can't be two 
    processes sharing the same 
  - AXE executes asynchronous tasks with dependencies (at the single-node level)
  - there will be at least two one MPI communicator on the IONs side (which will be used to execute 
    "normal" inter-IONs tasks (such as coordination))
  - the communicator is initialized at the beginning from the application

--------------

Although the discussion on workflows and how to implement a workflow execution engine is 
interesting, there are still basic problems that need to be addressed:

We need to answer, in concrete terms:

  - how does the analysis shipping server gets launched? at the beginning? for each analysis task?

  - how do new analysis tasks get pushed to it? how do jobs get submitted to it? this with respect 
    to the path that a request takes from analysis/external nodes down to the analysis executor.

  - if it's using the same MPI communicator that IONs are using, how does it get shared?

  - for an any analysis job:
      - how does the analysis application ships the analysis job? i.e. what's the interface? is it 
        implemented in HDF5?
      - is it sent from the same simulation app or externally?
      - is it sent through mercury? or is it sent directly to the analysis server (in case of 
        stand-alone service)?
      - is this part of the VOL plugin? or is it another type of extension done to HDF5?

  - for an h5view:

      - H5View objects are kept in memory on IONs and provide read-only access to the actual 
        underlying objects. If an analysis task decides to write data, how would this be done? we 
        need to take into account the fact that an IOD instance can only be used by only one app.
      - can we produce new results (such as the mean in the example) without having to write to a 
        new dataset? can the data be hold in the IONs memory?
      - how is it returned back to the client?

# Next steps

It would be helpful to write pseudo code of the procedure as answers to many of the above basic 
questions.


