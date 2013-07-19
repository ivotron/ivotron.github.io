---
layout: post
title: Intel - Analysis Shipping Basics
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

## Background

### Current way the EFF is initialized (server-side ; from Q4 demo).

  - there's a main file:

    > `hdf5/testff/h5ff_test_server.c`

    the mercury, axe and iod libraries are linked to this executable (referenced in H5VLoid.h), thus 
    the process space is owned by the server-side VOL plugin.

### Life of a Request (ignoring asynchry)

 1. An application running on CNs can make HDF5 function calls that are registered on the mercury 
    client. Those are defined in `hdf5/src/H5VLiod.c`.

 2. When an application running on CNs makes a call to an HDF5 function, the FunctionShipper sends 
    that call to an ION. **What ION is the call sent to?**. We can assume that all calls are routed 
    to the same ION (which it might be assigned by hashing the container name). This won't scale in 
    a real scenario but it might be the way is done for the demos.

 3. a function call gets received by the mercury server and there it is routed, which effectively 
    makes a call to the HDF5 VOL API.

 4. the IOD-VOL implementation doesn't handle any type of communication, it rather offloads that 
    responsibility to IOD. In other words, the IOD-VOL implementation doesn't have to deal with MPI 
    calls, it's just making calls to the IOD API.

**Questions**:

  - why are the wrappers in `H5FFpublic.h` not registered through mercury? or if they are, where is 
    that code written?

## Analysis Shipping

### Basic behavior

  - The analysis service is an extension to HDF5 that gets linked to the VOL executable. Let's say 
    it's exposed through a hypothetical `H5AEpublic.h` API (see below for alternatives).

  - The analysis execution library gets initialized with an MPI communicator, in the same way that  
    IOD does. This is used to communicate among IONs when executing an analysis task.

  - An analysis task (eg. `H5Query`) is sent from the application. Might be exposed through a 
    hypothetical `H5AE_execute()` function that receives as parameter the task to be launched on 
    IONs.

  - the piece of code that the analysis execution is running is basically a master/worker MPI 
    program that executes VOL calls in parallel[^vol]. Let's assume that this is implemented as part 
    of `H5AE_execute` in a hypothetical `H5AEimpl.c` .

  - each worker will send back to the master ION the result of its sub-task (eg. the list of values 
    that satisfied the query.

  - the master is in charge of creating an H5View object and "returning"[^noasynch]

[^vol]: assuming that the call can be handled in the same way that any other `H5*_ff` call, the 
difference will be that the VOL calls aren't invoked directly, rather, the analysis executor will 
first coordinate the task in order to have all the ranks in the MPI communicator make (in parallel) 
VOL calls.

[^noasynch]: I'm ignoring asynchrony for now, mainly because I don't understand well how the event 
queues work

### H5AEpublic.h

This API would contain functions that allow an application to send/receive analysis specifications 
to IONs. Through these calls the user would, at least initially, ship an `H5Query`.

**Questions**:

  - can it be part of the VOL API? Can it be generalized in some other way? there's a dependency 
  - can the behavior be exactly as any other call exposed in `H5FFpublic.h`?

## To-do

  - materializing an `H5View`
  - handling python scripts
  - handling external requests (not coming from CNs)
