---
layout: post
title: 'Exploring Trade-offs in Transactional Parallel Data Movement'
category: labnotebook
author:
  - name: "Ivo Jimenez, Carlos Maltzahn"
    affiliation: UCSC
  - name: "Jay Lofstead"
    affiliation: Sandia National Labs
tags:
  - txn
  - ff
  - poster
# following are beamer-specific
out-type: beamer
template: 'extended'
#classoption: "notes=show"
colortheme: "dove"
fontsize: 12pt
sansfont: 'PT Sans'
monofont: 'Monaco'
sansfontscale: '1.25'
monofontsize: 'scriptsize'
simplenavigation: 'yes'
nonumberontitle: 'yes'
bullets: 'true'
---

# The need for Transactional Atomicity

![][staging]

# The difference with Databases

  * In terms of ACID, we want:

      * **A**tomicity
      * **D**urability
      * Leave **I**solation/**C**onsistency to the clients

  * Single Transaction (vs. thousands)

  * Massive amount of cohorts (vs. hundreds)

# The approach

  * Assume that storage servers can do:

     * multi-version concurrency control

     * per-object visibility control

  * Clients handle consensus

<!--
    let the user handle Isolation
  -->

# Consensus Protocols

![][protocols]

# NBTA

  * **N**on-**b**locking **T**ransactional **A**tomicity

  * "HAT" formalization (Bailis et al. VLDB 2014)

  * In the context of Highly-available systems

  * Can also be applied in synchronous systems to achieve very low 
    overhead

# Features

  Protocol    Fault Model    Block   Async   Replication
 ---------- --------------- ------- ------- -------------
   NBTA          none         Yes     No        No
    2PC       fail-stop       Yes     No        No
    3PC       fail-stop       No      No        No
   Paxos     fail-recover     No      Yes       Yes

# Our goal

  * One-size-fits-all solution won't work

  * Let users pick based on their needs:

     * Length of job

     * MTTF

     * fault modes

     * etc

  * We want to explore trade-offs and characterize protocols based on 
    the user needs

# Preliminary Evaluation

![][nbta-vs-2pc]

# Future Work

  * Incorporate fault-tolerance

     * Cohort failure: can recover individually

     * Coordinator failure: 3PC, Paxos

  * Coordinate asynchronously

     * No need to wait for global consensus

<!--
   not the same than async I/O

   we don't have to wait for the
  -->

# Related Work

  * DOE's Fast Forward Storage and I/O. The FastForward approach is 
    similar to the NBTA protocol.

  * Fault-tolerant MPI make use of consensus protocols to identify 
    faulty processes.

  * Recovery in multi-level checkpoint restart.

# Thanks!

[staging]: images/labnotebook/2013-11-12-staging.png
[protocols]: images/labnotebook/2013-11-12-protocols.png
[nbta-vs-2pc]: images/labnotebook/2013-11-12-nbta-vs-2pc
