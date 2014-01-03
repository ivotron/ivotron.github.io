---
layout: post
title: 'Exploring Trade-offs in Transactional Parallel Data Movement'
category: labnotebook
author:
  - name: "Ivo Jimenez, Carlos Maltzahn"
    affiliation: UCSC
  - name: "Jai Dayal"
    affiliation: Georgia Institute of Technology
  - name: "Jay Lofstead"
    affiliation: Sandia National Labs
tags:
  - txn
  - ff
  - poster
out-type: pdf
latex-engine: xelatex
template: a0poster
papersize: a0b
columns: 3
columnsep: '100pt'
columnseprule: '0pt'
titleseparator: 'true'
mainfont: "PT Sans"
monofont: "DejaVu Sans Mono"
links-as-notes: 'true'
---

# The Road to Exascale

Exascale systems that are slated for the end of this decade will 
include up to a million compute nodes running about a billion 
execution threads. In this scenario, traditional methods that 
ameliorate I/O bottlenecks do not work anymore. _I/O Staging_ 
[^bb-link] [^adios-link] proposes designating of a portion of the 
nodes to manage I/O.

![staging]\ 

**The Need for Transactions**

Transferring a checkpoint or analysis output to the staging area (or 
from the staging area to long-term storage) is challenging, even at 
current petaflop scales. Transactions provide a framework in which 
users can easily reason about data movement across the I/O stack.

\ 

**The Challenge**

Traditionally, transactional systems assume that requests are 
initiated from a single client, and that each client's transaction are 
relatively independent of each other. HPC workloads don't fit these 
assumptions since all clients work in unison producing simulation 
output. A user would like to observe atomic and durable transfers 
across the I/O stack.

\ 

# I/O stack requirements

<!--
This allows the system to provide atomic and durable transactions, 
while leaving consistency (isolation) requirements to the user.

Existing transactional frameworks implement ACID semantics into the 
storage servers, which forces clients to make use of the consensus 
protocols implemented by the stack. 

  -->

In order to solve the multi-client scenario, recent work [^d2t-link] 
[^ff-link] proposes abstracting the storage with basic concurrency 
control capabilities and thus allow clients to manage isolation 
semantics. One way this can be achieved is by having storage servers 
that implement:

 1. Multi-versioning concurrency control.
 2. Object visibility control.

# Consensus Protocols

![protocols]\ 

# Performance/Usability Aspects

  Protocol    Fault Model    Blocking   Async   Replication   Overhead
 ---------- --------------- ---------- ------- ------------- ----------
   NBTA          none         Yes        No        No          0
    2PC       fail-stop       Yes        No        No          1
    3PC       fail-stop       No         No        No          2
   Paxos     fail-recover     No         Yes       Yes         3

**Table 1**. Several consensus protocols and their features. The NBTA protocol 
is a variation of the _Highly Available Transactions_ [^nb-link] 
formalization, providing _Read Committed_ isolation guarantees.

\ 

> **Our goal is to explore the trade-offs across the transaction 
coordination spectrum, identifying precisely where overheads are at 
and thus provide a toolkit for scientists to allow them to pick the 
most appropriate alternative for their workloads.**

<!--

  For example, 2PC can support fail-recover by incorporating passive 
  replicas.

J. Gray and L. Lamport, “Consensus on transaction commit,” ACM Trans. 
Database Syst., vol. 31, no. 1, pp. 133–160, Mar. 2006. 
<http://dx.doi.org/10.1145/1132863.1132867>

P. Bailis, “Non-blocking transactional atomicity,” Highly Available, 
Seldom Consistent, 29-May-2013. 
<http://www.bailis.org/blog/non-blocking-transactional-atomicity>

  -->

# Preliminary Evaluation


\  \  \  \  \  ![2pc]\ 

\ 

\  \  \  \  \  ![nbta-vs-2pc]\ 


# Related Work

  * The DOE's Fast Forward Storage and I/O project is implementing 
    transactional features into a next-generation stack. The 
    FastForward protocol used to implement transactions is similar to 
    the NBTA protocol referenced here.

  * Many proposals for fault-tolerance [^ft-link] in HPC make use of 
    consensus protocols to identify faulty processes. Our work is 
    complementary to these efforts.

----

\ \ \ \ \ ![doe]\ \ \ \ \ ![sandia]\ \ \ \ \ ![nnsa]\ \ \ \ \ ![srl]\ 

[^bb-link]: Liu et al., _On the Role of Burst Buffers in Leadership-class Storage Systems_. MSST '12. <http://dx.doi.org/10.1109/MSST.2012.6232369>
[^adios-link]: Lofstead et al., _Adaptable, metadata rich IO methods for portable high performance IO_. IPDPS '09. <http://dx.doi.org/10.1109/IPDPS.2009.5161052>
[^d2t-link]: Lofstead et al., _D2T: Doubly Distributed Transactions for High Performance and Distributed Computing_. CLUSTER '12. <http://dx.doi.org/10.1109/CLUSTER.2012.79>
[^ff-link]: _DOE Extreme-Scale Technology Acceleration. FastForward_ <https://asc.llnl.gov/fastforward/>
[^ft-link]: Stearley et al. _Investigating An API for Resilient Exascale Computing_. Tech Report. <http://prod.sandia.gov/techlib/access-control.cgi/2013/133790.pdf>.
[^nb-link]: Bailis et al. _Highly Available Transactions_. VLDB '14. <http://arxiv.org/abs/1302.0309>

[sandia]: images/logos/sandia
[srl]: images/logos/srl
[nnsa]: images/logos/nnsa
[doe]: images/logos/doe
[staging]: images/labnotebook/2013-11-12-staging
[protocols]: images/labnotebook/2013-11-12-protocols
[2pc]: images/labnotebook/2013-11-12-2pc
[nbta-vs-2pc]: images/labnotebook/2013-11-12-nbta-vs-2pc