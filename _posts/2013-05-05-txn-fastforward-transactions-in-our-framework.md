---
layout: post
title: TXN - Meeting Notes
category: labnotebook
tags:
  - txn
  - hpc
  - transactional-storage
  - fast-forward
---

# {{ page.title }}

In [@bent_milestone_2013] (specifically section 4.5), the high-level transactional semantics of IOD 
are described. Our goal is to replicate them in our framework. The following is a preliminary plan 
on doing so.

## Status

Transaction status in IOD are:

  - invalid
  - started
  - aborted
  - durable
  - finished
  - readable
  - stale

whereas we have:

  - new
  - in-progress
  - voting
  - voted
  - committing
  - committed
  - aborting
  - aborted
  - creating-sub-txn

if we ommit the transitional states (committing, aborting, voting, creating-sub-txn):

  - new
  - in-progress
  - aborted
  - voted
  - committed

the above almost resembles FF's:

  - started -> in-progress
  - aborted -> aborted
  - finished -> voted
  - readable -> committed

First question is, does these statuses are semantically equivalent? I think they are, with minor, 
negligible differences.

We're missing `invalid`, `durable` and `stale` (and `new` from our framework doesn't map to anything 
on the FF side). From [@bent_milestone_2013]:

  - `invalid`: any transaction that is referenced that hasn't been started
  - `durable`: a transaction that has been migrated to DAOS
  - `stale`: a transaction that hasn't been flushed out of the burst-buffer (BB) but that has 
    already been migrated to DAOS.

Since we're assuming that we run on a fast fabric (i.e. we can discard DAOS-related states), from 
the above, `invalid` is the only one missing. We can easily simulate this state by checking if a 
referenced transaction exists, if it doesn't, we return that status.

## TID selection

The FF doc specifies `iod_container_query_tids` as a function that can be used to obtain the ids of 
the transactions that are durable, written (a.k.a. committed) and readable. We can easily replicate 
this since we're ignoring DAOS-related statuses, i.e. we only care about the latest committed ID 
(i.e. user will write to `latest_committed + 1`).

## Transaction synchronization

There are two ways in FF to coordinate a transaction, client-side vs server-side. Since both run on 
the same interconnect, they in theory can be comparable. In our project we will compare their 
server-side method against ours (and possibly other alternatives). The description of their 
server-side coordination follows:

> Application ranks only need to start and finish/slip this TID separately and independently. For this method, user needs to pass in the number of participators (num_ranks) for this transaction. IOD needs this number to track whether or not all participators have finished this transaction. The “num_ranks” is number of CN-side ranks as function shipper 1:1 forwards/translates I/O calls from CN to ION. IOD will need to do lots of internal P2P message passing for transaction status synchronization. As IOD does not know CN ranks' process group information and function shipping server does not create appropriate process group based on CN ranks’ process topology, so IOD cannot use group collective communication. When the number of participators is large, the status synchronizations will introduce considerable overhead and latency at IOD layer
>
> A possible optimization exists if IOD can know that this TID is for all CN ranks – we can call it as global transaction. For global transaction, IOD can use the global communicator across all IODs to do similar collective communication by building collective spanning tree to reduce the lots P2P message passing. For this optimization, IOD needs to know two extra parameters: 1) total number of CN ranks and 2) the number of CN ranks which are connected to this IOD. User can pass in these two parameters when calling iod_initialize. If application can create dynamic processes, then user should re-call iod_initialize when dynamic processes are added. This possibly is a too high requirement to upper layer, so basically IOD can only use lots of P2P message passing for transaction status synchronization.
>
> However, even the higher cost of the multiple P2P messages can be mostly avoided when applications are not extremely asynchronous. Each IOD will count the number of open references for each TID and only communicate with the transaction leader when it sees the TID for the first time and then again when the reference count goes to zero. In the best case, this will be two messages between each IOD and the transaction leader. In the worst case, when no two processes sharing an IOD ever have the transaction open simultaneously, then each IOD will communicate with the transaction leader once to start the transaction and then again for every process participating in that transaction on that IOD. It should be noted that this extreme worse case is expected to be extremely unlikely as this would mean that the asynchrony of the application would be so large that processes would be 1000’s of transactions removed from each other. In such an extreme case, the application is encouraged to do its own monitoring of transaction completion as described in method 1.

I don't see the above description being sufficiently detailed in order to differentiate from our 
own. Or in other words, it seems that what we're doing could be embodied by their second paragraph. 
What do you think?


# Next steps

  - should we be looking at fault-tolerance issues?

  - determine if we want to be IOD API compatible. This will potentially allow us to plug IOD's unit 
    tests to our framework.

  - two possible immediate next actions:
      - use the current implementation as our baseline and begin to get experiment numbers
      - discuss more about how to have FF's transactions as our baseline

# References
