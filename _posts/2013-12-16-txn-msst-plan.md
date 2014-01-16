---
layout: post
title: Plan for MSST paper
category: labnotebook
tags:
  - txn
  - msst
  - experimental-plan
---

On our last meeting we discussed, w.r.t. parameters of the REF_COUNT 
(which tries to mimic FF's client-side approach) transactional 
coordination:

 1. communication-tree topology
 2. number of txns (how often an app commits)
 3. size of txns (how big is data being written)
 4. bulk- vs. message-optimized network
 5. asynchronous coordination

I just pushed code that implements arbitrary k-ary tree topologies 
(#1) that the leaders use to communicate among them. It also contains 
a timing test that runs with distinct parameters that I use to obtain 
experimental results. I can present numbers from my laptop on our next 
meeting. I've done my best to make this portable (using cmake) so that 
testing on other platforms/systems is straight-forward. Since our 
cluster hasn't been turned on yet, I haven't been able to setup a 
testing environment there. I will on Jan 2nd, after power is 
re-established to our building.

I'll work next on #2 and #3, since it's the more straight-forward 
thing to do. For #4, I feel less prepared and will have to review 
papers/documentation.

------

No. 5 is something we didn't discuss but I'd like to suggest it as 
part of the list. One option is to assume complete asynchrony and 
leave every rank continue regardless of where the others are [^note]. 
This might be too extreme, or not. This essentially corresponds to the 
multi-leader approach approach of FastForward (reference counting and 
watching for a transaction to get done in order to mark it as such). 
We can potentially do better if we take into account the fact that we 
interact with an object-based API [^objects].

[^note]: in terms of I/O, of course; apps might need to synchronize 
but that's not our business.

[^objects]: this statement assumes IOD, DAOS, RADOS, S3, etc. is being 
used in the back. We can in theory turn any "traditional" I/O 
interface into an object-based one. For ADIOS, it's straight-forward. 
For MPI-IO, we make every block an object. For POSIX, we can have 
multiple files (one per rank) ala PLFS.

If we consider the fact that we interact with an object-based API, we 
can reduce significantly the synchronization overhead (without going 
to the extreme) if we assume that coordination should be required 
**only** on shared objects. For example, if 4 ranks (out of 1024) are 
writing to an array's shard, they should be the ones that are 
coordinating. For K-V pairs, there's no coordination required unless 
more than one rank writes to the same key.

Now, if we operate like the above, that means that there's never a 
point in time where the synchronization needs to be global, unless all 
ranks write to a single object concurrently, in which case the object 
should be resharded accordingly.

The question now is: how do we determine that a higher-level object 
(eg. a container of objects) consisting of many objects is at a given 
version/transaction? For example, for 1024 array shards, how do we 
know that the multidimensional array that those 1024 arrays correspond 
to are **all** at a given version x? We have at least three 
alternatives:

  1. fsync-like: check sequentially if every node of the storage 
     system contains objects that are at version-x. this is similar to 
     fsync and will potentially cause bottlenecks.
  2. create a global index (eg. a spanning tree) that determines when 
     a given container is at version x. As soon as an object is 
     finished being written to, an entry in the index is added. When 
     someone queries for the status of the transaction, we start from 
     the leaves up in order to determine transaction status.
  3. assume the app knows what it's doing and try to read version x 
     for the given object. If it doesn't exist, return an error 
     immediately (this won't work in an async scenario since the 
     operations might be still in flight).
  4. wait for the appearance of the requested version, which would 
     work for async backends, with the problem that we might wait for 
     a long time.
  5. use ref-counting on a per-object basis
  6. create a membership list (nodes in the storage system) by 
     initially identifying the objects that will be written in a given 
     transaction and then implement a hierarchical gather on all the 
     members. This might be similar to 2.

A possible optimization for (3) and (4) is to check if the version is 
being written at all (if a txn x has been opened) and fail immediately 
if it isn't. An optimization for (6) is to implement a "conditional" 
gather, in which a global node is designated so that when a member 
from the gather responds to its leader that it doesn't have the 
version in question, it also communicates this to the global node, and 
this in turn replies to the user that is querying for the txn.

**note**: I think I'm hitting something fundamental here. I should 
give it more thought. This feels a lot like Eric Barton's epochs, but 
a little bit more structured, i.e. the client-side of it. There must 
also be related work (the Pyramid arraystore, or SciDB's versioning) 
might have info on this hierarchical (objects within objects, all of 
them part of the same version) way of determining versions.

**note2**: another way of approaching this is to have a "prepare" 
phase in which we obtain the number of sub-transactions that make up 
the global transaction and just check for the last one being written. 
The key here is to assign id's "on the fly". I think this can be 
reduced to FF's multi-leader approach.

**note3**: another way is to just tell the backend the number of 
`finish()` calls that will be executed ala FF. In the extreme case, 
when there's an IO node per rank, this is as extreme as the one 
described in the first part of this section. When there's, say, CN:ION 
ratio of 100:1, keeping track of `finish()` invocations becomes 
similar to #1 from the above list of alternatives.

**note4**: thus, having said the above, there are 3 types of 
coordination:

  - fully synchronous (as we are doing right now with our ONE_ROUND 
    txn), that is handled entirely by the clients.
  - semi-synchronous by coordinating only on shared objects, with many 
    alternatives to determining whether something has been committed 
    or not.
  - fully asynchronous by reference-counting as in FFs, which has more 
    overhead (there's a last round of "are you done yet?" 
    communication among the ref_counters).
  - deferring to read-time to determine when something is done.


open question: how do we coordinate overlapped writes?

-------

We also discussed two other issues: process placement and determining 
global/regional/local info needed to support different fault modes. 
I'm deferring these at the moment. In the meantime, for the former, I 
found 
[this](http://clusterdesign.org/2012/11/finally-a-topology-aware-mpi-implementation/):

> Good news from the Supercomputing-2012 (SC12) conference: ten 
collaborators (including a talented team led by Dr. Dhabaleswar K. 
Panda) presented a paper on a new approach for assigning processes to 
compute nodes in InfiniBand networks.
>
> Roughly, it works as follows: a plugin for OpenSM subnet manager 
retrieves a network topology by querying switches, topology 
information is passed to the MPI library (MVAPICH2), and finally the 
MPI library ensures that MPI processes that need to exchange large 
volumes of data are placed onto physically close compute nodes â 
i.e., within the minimum number of switch hops â or, ideally, 
within a single compute node.
>
> The method allows to reduce the execution time of parallel 
applications by 6% to 15%, depending on the application and the number 
of MPI processes in a job: large-scale jobs appear to benefit more 
from the topology-aware placement.

I'll read the paper later and can present it if you want.
