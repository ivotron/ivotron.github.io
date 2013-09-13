---
layout: post
title: Intel - Meeting Notes
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
  - txn
  - wf
---

# {{ page.title }}

Instead of writing my questions on things that aren't clear about FF all over my notes, I'm 
selecting a single entry to register all of them. These are questions on many aspects of FastForward 
that I would like to understand better. Many of these might give rise to interesting research 
projects (masters/phd thesis maybe?)

## General (more than one layer)

  - handling dependencies of asynchronous events resembles a lot the way in which dependencies are 
    handled in a transactional engine. For example, in the description of HDF5 async:

     1. An app creates an attribute
     2. Another app writes to the attribute

    number 2 depends on number 1 since an attribute can't be written to it if it hasn't been 
    created. In the above example, my previous question is illustrated as well. Since IOD is logging 
    operations, I think it will be more efficient to let IOD handle the asynchrony and have VOL 
    operate transparently into the IOD API

  - w.r.t. the new HDF5 Map object, it isn't clear why is this needed. Would it be better to reuse 
    the attribute object but implement it internally as a map? Not sure why this is needed.

  - I get the sense that the layering of FF will be very costly. This has to be proven 
    experimentally but I think that the Ceph approach of centralizing the knowledge will turn out to 
    be more efficient.


## HDF

  - why is a separate HDF async execution engine needed? Is it because the mapping between HDF and 
    IOD objects? Isn't IOD including an async engine of its own?

  - how's the coordination being done? There's a part in the detailed design document that talks 
    about detection of dropped operations over transport layers.

  - a VOL plugin that achieves the same N-N sharding that PLFS does could be written (see below in 
    PLFS section).

## IOD

### PLFS

  - I wonder how a PLFS alternative in Ceph would look like. I think it would be definitely simpler. 
    One thing I think it would improve is the global index. If there's a convention on how to 
    "stick" the file together, i.e. doing something like CRUSH but for a single PLFS virtual file: 
    given an offset and length, the system knows how to locate the file without having to consult 
    the index and get the pointer to the actual physical file.

  - what's the local (BB) file system used on the IOD? 

## Transactions


In general, FF's transactions are concerned with durability and atomicity, leaving isolation to the 
app. Can we find another approach, that is more strict but doesn't affect in terms of concurrency. 
The main difference between a transactional system and EFF's is that the latter allows to have 
multiple versions of history.

----------

I'm personally curious to see if an "intermediate" approach would work better. I suggested it in one 
of our meetings: calculate a-priori transaction IDs , plan the work by calculating 
dependencies/locality w.r.t. isolation and execute without coordination (the last write is what we 
care about).

Pros:
  * no need to worry about isolation (from users point of view)

Cons:

  * how do we identify operations (might need a high-level lang)

----------

The FF assumption is that commits are done strictly in transaction ID (TID) order:

    1 - 2 -- 3 - 5
          \
           - 4 - 6

or alternatively:

    1 - 2 -- 3 - 4
          \
           - 5 - 6

In the example, anything above 3 can't commit, even if it doesn't have (bad) implications on 
subsequent transactions. If we know that 4 (or 5 in the alternate example) have committed, we could 
allow 6 to commit too without waiting for 3.

----------

Another idea: how can we partition the "transactional space" in such a way that we have coordination 
locality? This might be similar to sub-transactions. Would this be related to granola's independent 
transactions?

