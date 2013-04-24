---
layout: post
title: Meeting Notes
category: labnotebook
tags:
  - ff
  - transactional-storage
  - iod
  - fast-forward
  - hpc
---

# Key questions IMO

  - Still not clear what the isolation level is. I really want to get this right in order to do 
    meaningful comparisons with OLTP-like numbers (eg. H-Store). It might not matter though.

  - In general, I think we understand enough of the functionality in order to build this on top of 
    Ceph:

      - at this point, it's clear that what they want is to support checkpoint/restart workloads. 
        They find atomicity and durability (form ACID) to be what it's important to keep track of at 
        the system level, while leaving Isolation to the app to be handled.

      - do we need to blindly replicate the required behavior or are we supposed to modify the 
        design so that it is more generic?

      - if we don't, that is, if we need to to look for alternatives to their light-weight 
        transactions, where should we start? Do we still need to code their epoch approach in order 
        to identify others? Can we work on paper as Noah mentioned?

# Notes on IOD API

From `iod_types.h`

  - layout stuff: do we have to understand it, cause I don't.
  - I assume `IOD_LOC_CENTRAL` means located in DAOS (not sure why they picked 'central' as the 
    word)
  - what are KV hints used for?


# Jay

  - since the IOD consistency semantics are driven by the PLFS/HDF people, if we want to have more 
    use cases of what this might be used for, we can look at their workloads to see if this is 
    enough for them.

  - in FF IOD, it's not clear how they will handle failures. What happens if a failure occurs, there 
    are two pieces:

      - discovery (when has something failed)
      - reaction (what do we do)

    unless there is a fault-tolerant MPI stuff, it's going to be really hard

  - how is this done today?

      - MPI has this MPI_BCAST_FAILURE
      - how does a there's a checkpoint
