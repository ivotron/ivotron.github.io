---
layout: post
title: Notes on Eric Barton's LUG 2013 talk
category: labnotebook
tags:
  - ff
  - transactional-storage
  - fast-forward
  - hpc
---

# {{ page.title }}

<iframe width="560" height="315" src="http://www.youtube.com/embed/pn_EEbmohDU" 
frameborder="0" allowfullscreen></iframe>

Watching the talk was very insightful. I think the first part, where he describes the principles is 
very important (see my notes at the end if interested in a summary on these principles).

From these principles, the ones that concern the IOD layer IMO are basically two: async I/O 
(function shipping) and "light-weight" transactions. We were assigned with the task of questioning 
these principles and so far we have discussed whether the need of these "light-weight" transactions 
is appropriate or not, which has allowed us to get a better understanding of the stack. Another way 
of framing the discussion could be in terms of the alternatives to each of these two key decisions:

  - is IOFSL appropriate in this context? what process models are not supported by it? Is it generic 
    enough?

    > **Noah**: IOFSL is likely built right now (it's out of Argonne) just for POSIX I/O function 
    shipping. Since the range of possible functions being shipped will increase, it seems as though 
    IOFSL will become more general if they end up re-using that project. That's probably an over 
    simplification.

  - what alternatives to having "light-weight" transactions are there?

    > **Noah**: Good question. Starting with a precise definition of what is required of 
    light-weight transactions might be starting point. Also, I'm inclined to believe that here 
    "light-weight" refers to the writers, and as per our discussion yesterday the complexity is 
    moved to the read side. Maybe it's worth looking at how a balance could be achieved

    > **Me**: I'm trying to get the use case point of view since I'm not 
    familiar with HPC workloads. Jay sent a link to [this][pio]. I'm going back 
    to the general requirements for checkpoint/restart. This paper gives an 
    overview of approaches [@capello_toward_2009]. I'm not sure if this would be 
    helpful though. Would it suffice to see it from a very high-level point of 
    view? E.g. like what we discussed on Tuesday of having a matrix or any other 
    distributed structured that is being updated concurrently my thousands of 
    processes?
    > I'm in the search of related work on "transactional primitives", to see if 
    I can find anything that talks about write- or read-optimized approaches and 
    their trade-offs.

    I personally don't know the answers to these but I think this is a direction we might explore, 
    depending on how fundamental our questions have to be. Alternatively, and assuming that these 
    principles are taken for granted, IMO the next level we can consider is their implementation 
    choices:

  - client-side vs. server-side coordination: (such as what we're doing with Jay)

    > **Noah**: I like this idea of having client coordinate on a transaction. However, I always 
    assumed clients would be doing this. If this functionality is something that will be commonly 
    needed by applications, then sticking it in middleware with a good programming model is key. I'm 
    under the impression now that this is what Jay is working on. So long story short, I think 
    client-side is necessary, and server-side might be an optimization point.

  - collective I/O alternatives. They have an alternative hierarchical, gossip-based communication 
    scheme in DAOS; how would it compare against' Paxos' based ones (such as Ceph's). Would this 
    matter at the IOD layer? Or are they envisioning using the current communication routines?

    > **Noah**: I think the collective I/O referred to in the slides is to more in line with MPI-IO 
    collective, which achieve large reads and writes, and isn't about consensus during failures 
    (paxos) or gossiping.
    > **Me**: You're right, MPI-IO-like communication is what he refers to as 
    collective I/O.  The presentation references to CN-side collective I/O at 
    the beginning and then at the end he talks about how they're planning to 
    implement the atomic broadcast in DAOS through this O(logn) peering 
    algorithm (which differs from chubby-like stuff) [@ganesh_peer--peer_2003].
    They refer to the above as server collectives, which is what got me confused 
    but it is a separate thing. This might be used by the IOD too though, I'm 
    not sure.

  - Merging IOD and DAOS into a single layer. Eric explains their decision of having separate 
    layers:

    > remove the responsibility of the user to have to directly specify what's on disk and what's on 
    flash. Instead, the user should only have to decide what's persistent and let the stack manage 
    all this in his/her behalf. So IOD is there in order to hide the complexity of the stack. App 
    developers are worried about doing the science and not the low-level storage decisions

    Is the above Lustre specific? Could we achieve the same degree of automation in Ceph?

    > **Noah**: I don't think it's Lustre specific in the sense that Ceph couldn't do this. Or 
    rather, neither can do it without changes.

   - anything I'm missing

------------------

Below are the notes I took while watching the video. The headers refer to slides numbers. Video at 
<http://www.youtube.com/watch?v=pn_EEbmohDU>

# Motivation

the motivation of the design of the FF

## 4

  - main goal: have scientists interact with the data in very expressible ways. Support both:
      - data-to-compute
      - compute-to-data

  - scientist should be in total control on how data moves throughout the exa-scale infrastructure

  - excessive locking is a no-no (Jitter must be non-existent)

  - no "one-size-fits-all" from the storage point of view:
      - different fault-tolerance schemes
      - different consistency schemes

# Principles

## 5 Horizontal scaling without Jitter

  - non-blocking APIs

  - decoupling of apps from storage

  - think of a communications library: should be non-blocking all the way down

  - "initiation procedures and completion events" resembling the [portals 
    API](http://en.wikipedia.org/wiki/Portals_network_programming_api)

  - **questions**:

      - what alternatives to the Portals-like "register-and-wait" model are there? Should we 
        consider them?

      - what process models can't be supported in this approach?

## 6 System must act as a single entity

  - example: Lustre knows about failures through a gossip-like scheme which potentially leads to 
    inconsistencies since a client might be interacting with an invalid node. **Question**: can this 
    happen in Ceph? How "fast" is CRUSH?

  - I/O communication is inherently (and relatively) slow: so use it for moving data and not for 
    coordinating.

  - client-side has fast fabric: push up as much as possible and let the app decide (fast) about 
    coordination-related decisions.

  - BUT, don't sacrifice the capability of the client-side communication network by having blocking 
    APIs: don't create a separate kernel-routed communication channel, piggyback on the computation 
    communication's library that the app is already using in order to transfer coordination messages

  - use collective I/O as much as possible in order to have scalable client-side communication:
      - a process leader that communicates from/to the storage (shared buffer)
      - pushes that info to their peers `local2global`
      - conversely whenever something has to be communicated to the storage side do a `global2local` 
        conversion and then communicate.

## 7 Locking and Caching

### Consistency

  - **main goal**: eliminate locking entirely

  - Storage system shouldn't be used for message passing.

  - Storage should be used only for producer/consumer tasks => store results of a simulation, read a 
    previous checkpoint.

  - **Consequence**: application has to coordinate itself and not through the storage system. 
    Tightly coupled process should coordinate themselves and just ensure themselves that whatever 
    they write is consistent (non-conflicting). **Serialization logic belongs to the app**.

  - enable coupling only for producer consumer case

### Caching

  - assumption in distributed FS: should be possible for a client to do non-overlapping writes 
    without having to handle this itself.

  - however, if this is coupled with caching (caching is done at some block-level granularity), then 
    we get false-sharing and for a shared file, clients get involved in a locking storm and this 
    causes all clients to be coordinating for every single write operation that clients do go 
    through the network and coordinating. Worse than this is if the individual clients don't align 
    their caches..

  - caches should be used only to buffer writes that will eventually be pushed down in chunks.

  - if a cache is used as a way of avoiding reading something n-times, then we have to resort again 
    to a blocking-based approach.


## 8 Atomicity/Durability but no Isolation

  - don't want the application to pause at all when there are failures

  - guarantee atomicity/durability without dealing with isolation-level issues (serializability): 
    Have a way of describing a transaction in a non-blocking manner, and let the application 
    indicate when something is done and when it isn't. This is the key difference between db-like 
    transactions and FF's version of them

  - nestable transactions doesn't refer to having nested transactions but to being able to nest the 
    storage layer into higher-level layers and let the apps decide when they


## 9 Transactions

  - label all operations with epoch #

  - writes get at arbitrary order to storage, total disorder in time but maintain total order w.r.t. 
    epoch #

  - by the time I/Os get to the storage device, this means that there needs to be a versioning file 
    system that ensures that writes are applied in epoch order such that what you see when you read 
    from storage is "as if" all the writes were done in epoch order

# Implementation

## 10 Stack

  - object storage at the bottom. Apps should be able to access the object model directly (remove 
    POSIX). This is similar to RADOS but now we have transactions.

  - on top of that, since now we have transactions, we can have on top of it many HA schemes can be 
    implemented.

  - the decision to have a separate IOD layer is to remove the responsibility of the user to have to 
    directly specify what's on disk and what's on flash, instead, the user should only have to 
    decide what's persistent and what not and let the stack manage all this in his/her behalf. So 
    IOD is there in order to hide the complexity of the stack. App developers are worried about 
    doing the science and not the

  - analyzing

# Sub-projects

## 11 Scalable communication

  - collective communication among the servers in a fault-tolerant way: gossip

  - Main difference between this and Chubby/Zookeeper-like approaches is that this is implemented in 
    the OSDs themselves, that is, there's no need to keep a Paxos-based service that holds the valid 
    state in the system

  - on a gossip round, every member picks a set of peers (which and how many is part of the 
    protocol) to communicate with this results in having fault-tolerant broadcast (O(log n))

  - numbers: in a 10,000 cluster, if the average communication speed among peers is 1ms, a 
    fault-tolerant broadcast message is done in 5ms.

  - reference on this [@ganesh_peer--peer_2003].

## 12 VOSD

  - CoW as a way of implementing transactions

  - at each epoch commit, a snapshot is taken

  - between epochs, there is "log-on-arrival" for every write.

## 13 Containers

  - 11 and 12 allow to implement containers

  - think as a PGAS with three dimensions:
      - shard [1 - num-of-OSDs]
      - object name
      - offset

    for example:

        20.7a3b.1024

    which means OSD #20 object 7a3b and offset 1K.

  - an object exists always. If an object is read and hasn't been written to it before, it returns 
    zero.

  - again, there's support for atomicity and durability but not isolation.

## 14 IOD 15 HDF 16 Follow-up

  - nothing new here

[pio]: https://www.mcs.anl.gov/research/projects/pio-benchmark/
