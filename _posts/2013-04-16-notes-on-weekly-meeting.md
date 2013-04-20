---
layout: post
title: DAMASC Weekly Meeting Notes
category: labnotebook
tags:
  - fast-forward
  - hpc
  - iod
---

# {{ page.title }}

Members present on meeting: Aaron, Noah, Ivo, Carlos, Adam, Joe

We discussed the IOD API again.

# use case

  - main use case: checkpointing / restart
      - concrete example: adaptive mesh refinement (AMR): a way of marking what things have been done 
        and what hasn't at different resolutions (generating a transaction for each computing result). 
        The scientist will eventually say, I'm done with these 10 small changes, go and create a new 
        transaction (possibly pushing it to DAOS). When they flatten a checkpoint, the smaller 
        "transactions" get "moved" up to a global checkpoint/version TID that is visible (at IOD; at 
        DAOS level if it got pushed down to long-term storage). If that data got wiped out, then the 
        smaller transactions aren't visible. If another job needs to read something that is not in BB, 
        it can be loaded to the BB (from DAOS) again in a consistent way: "get me this cell at 
        transaction TID".

  - other use cases: graph builder writing hdf5 files and then graphlab running on top of the stack. 
    Another one is domain-specific languages stuff.

# transactions

  - you can't write/read on a transaction at the same time with the goal of avoiding 
    inter-transactions. Most of the restrictions that are imposed (that seem to come out of nowhere) 
    by the architecture/design documents are motivated by having all these questions been answered 
    by the application, i.e. the app developer has to be the one that ensures that there's no 
    conflict inter- and intra-transactions.

# function shipping

  - function shiping is the most immature piece of component (deliverable is next calendar year).

  - will be built on top of IOFSL

  - they're also using DBS (proprietary stuff that translates )

  - the use case they're targeting would be to have some sort of viz/analysis app that would 
    understand the data and say "calculate this visualization (code shipping) on this TID"

# checkpointing formatting

  - we can think of it as a readable hdf5 file (there's a 1:1 relationship with IOD container and 
    the hdf5 file)

