---
layout: post
title: Initial Thoughts on D2T and Integrated Application Workflows
category: labnotebook
tags:
  - dtm
  - hpc
  - transactional-memory
  - d2t
  - transactional-storage
---

# {{ page.title }}

> **tl;dr:** We would benefit by characterizing D2T's transactional characteristics. After doing so, 
we can have a conceptual/technical framework in which we can reason about the transactional issues 
involved.

After reading the D2T paper, I've been intrigued by the use case. Coming from the DBWorld, I hadn't 
seen the MxN requirement before and to the best of my knowledge no one from the hard-core db 
community (eg. SIGMOD/VLDB) has looked at many clients orchestrating a distributed transaction. I 
went back to my bibliography repository and the most closely related topic is that one of closed 
nested, workflow-like, extended transactions and more formally the ASSET framework described in 
[@biliris_asset_1994]. BTW, there's a nice survey in [@wang_survey_2008][^1].

While searching for literature on the subject, I stumbled upon the topic of *Distributed 
Transactional Memory (DTM)*[^2] which I wasn't aware of. I knew about STM since I've used Akka[^3] 
in the past, but I didn't know people were taking it up to the distributed level. I wonder if you 
considered it for your use case. The Mx1 pattern comes naturally in STM. DTM is looking at pushing 
this to the MxN level, so they have dealt with these kind of issues. In particular 
[@turcu_closed_2012] extends DTM to support (closed) nested transactions while [@turcu_open_2012] 
looks at open nesting. There are a couple of implementations that look interesting: HyflowCPP from 
Virginia Tech and GSM from ORNL (for the Chapel language).

[^1]: which is complete up to 2007, that is, it excludes the whole NewSQL recent movement 
[@bailis_hat_2013]. It doesn't talk about transactional memory neither.

[^2]: the thesisi on Hyflow [@saad_hyflow_2011] contains a very nice taxonomy of the DSTM work. It 
also describes the chronological developments in the area.

[^3]: they have coordinating transactions through the use of commit barrier's 
<http://my.safaribooksonline.com/book/-/9781849518284/7dot-software-transactional-memory/id286775732>

Regarding the project, I have the following observations/questions.

## On the use cases

  - Is 'data staging' similar to what a burst buffer does? So the idea here is to have computation 
    to push checkpoints to a staging area for analysis?

  - Does the test included in the tarball you sent captures the CTH use case? In general terms, can 
    we describe the use case as having transactional access for parallel NetCDF files?

  - For second case that deals with configuration, it wasn't clear to me why this couldn't be 
    accomplished by Chubby/Zookeeper. I wasn't able to identify the many-client nature of the use 
    case.

## Categorizing the protocol

I would describe the D2T protocol as "distributed coordinated 2PC", since it looks like nested-2PC, 
with the client synchronization variant. I think we would benefit if we could characterize the 
transactional aspects of the target workloads in terms of:

 1. nesting
 2. transaction synchronization
 3. consistency semantics

For 1, I already mentioned closed vs. open transactions. In the first one, the scope of the 
sub-transactions is limited to the parent's, whereas in the second one, whenever a sub-transaction 
commits, it is visible globally. For 2, there are many variants, but the main ones 
[@muller_commit_2010] are consensus-based, coordinator-based and token-based (I guess D2T is 
coordinator-based?). For 3, it would help if we could determine first if the targeted workloads 
require weak or strong consistency semantics. In any case, we would need to further sub-categorize 
depending on what we find. In the case it's strong (which is what I think), the Granola 
[@cowling_granola_2012] categories are a good alternative to use: single-node, coordinating 
(2PC-like) and independent.

## On ACID

The D2T paper describes how the commit protocol achieves ACID but I think this only covers 
atomicity. In other words, I got the impression that the only isolation level that the protocol 
achieves is Strict Serializability, am I right? That is, once the parent transaction initializes no 
other transaction can run concurrently. If it actually can, then it wasn't clear to me how the 
system deals with consistency issues (how it deals with conflicts), eg. the classic bank transfer 
example. I tried to look for answers to this by browsing through the code but I couldn't idenify 
anything related to this. I guess my main question is: is the purpose of the protocol to support 
concurrent transactions, or just consistent strict serializability, i.e. sequential (top-level) 
transactional execution?

## On DTM

Lastly, if DTM turns out to be something that can be used for the targeted use cases, there are a 
couple of ideas that occur to me. First, I noticed that Trios has support for RDMA. It would be 
interesting to see how DTM can benefit from RDMA.

Secondly, if something like HyflowCPP is used. I'd be curious to see how this could be integrated 
with transactional storage. There is already work looking at the issue of checkpointing DTM 
[@turcu_exploring_2013] in the context of recovery. An interesting direction is to look at how this 
checkpoints can be flattened/made consistent and pushed them down to a transactional storage 
backend.

## Next

  - Continue analyzing the transactional aspects of D2T and the use cases in order to characterize 
    them accordingly. This can help greatly to create conceptual/technical framework in which we can 
    reason about it.

  - Setup the `txn` project dev-env (I should be able to run `test/*.c`).

## References

