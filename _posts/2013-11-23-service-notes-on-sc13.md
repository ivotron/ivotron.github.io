---
layout: post
title: Service - SC'13 notes
category: labnotebook
tags:
  - service
  - sc13
  - notes
---

# chat with Tom Peterka

- there is a followup paper that bench marks DIY and it includes a 
  syntetic workload generator and presents results
- they don't plan to support the execution of workflows, rather they 
  assume DIY is "inside" a node of a DAG workflow.
- DIY might not work well with distributed graph processing due to the 
  same issues that are present in Graph lab and friends (graph setup, 
  skewness, etc)
-There is a decompose mode where the user can specify the exact 
chunking decomposition that the system is expecting from the l/O  
layer

**ideas**:

- make DIY scriptable. Instead of embedding a scriptable runtime, make 
  DIY at a scriptable level (create bindings). We can think more about 
  this
- ask Tom for get the benchmark generator
- see how the user-specified decomposition can be plugged to IOD

# chat with Quincey and Jay

- they want to consolidate RPC efforts
- MPI standardization

# WORKS '13

estimating runtime for WF (WORKS) USC Pegasus

- Kicks tart profiling tool
- profile montage,epigenomics, periodogram workflow
- online way of capturing stats and try to estimate runtime
- taking mean; sometimes works but some it doesn't
- find correlations since it allows for elimination of some readings
-when that doesn't work, use clustering (DBSCAN on-line algorithm)
- they wrap all ottneabove in a monitoring loop using MAPE-K

Q:
-what type of corrective actions can you take once you detect errors? 
in general what are the estimations results being used for?
- how would you handle external factors like system load?
- **idea**: how would all this be changed if workflows were 
  declarative described. Can anode in a workflow be abstracted so that 
  algebraic approaches are applied

# fault-tolerance tutorial

- fault vs error vs failure
-hard (crash-stop)  vs. soft (byzantine?) : very subjective terms, try 
to keep away from them
- where do errors come from? lots of places
- 8-24 hour AMTBF (application mean time between failure)
- DOE is trying to target 24 hour . 6 years ago DOE did an estimation 
  of 35 min. MTTF in exascale projections. But it wants to target 24 
  hr
- GPU to CPU SHOC benchmark from ORNL
- app vs. system checkpointing
- in practice, most faults come from RAM and SSD, NVRAM, etc

blcr (system level)

- Kernel-level, completely agnostic from app POV
- requirement: MPI needs to Know how to checkpoint
- the library doses all the local-level stuff and provides hooks so 
  that MPI-based coordinators connect to it. So itprovide the APIs for 
  recovery.ing
- there's a Linux module that handles checkpoint/ restart. B LCR might 
  migrate their APIs to this to avoid Kernel maintenance
- it supports a sync check pointing
- openmpi embeds BLCR and it thus makes it transparent (MPI 
  coordination is already baked
-DEGAS project

mohror (application level)

- the app is more smart
- small size of checkpoints
- i/O can be varied: MPI-IO, HDF5 etc
- One of the factors that affects checkpoint perf is ratio of 
  readers-to-writers 
- multi-level libraries : FTI , SCR, charm++

- **idea**:  can we do multi-level checkpoints on an  async, 
  RPC-enabled stack such as FF's? In other words, can we have SCR run 
  on top of async, non-posix IO?

11/18

# fusion IO

opennvm.github.io

Site that holds standard-compliant nvm code

**idea** use this to learn how nvm is beig programmed 

# sds

**idea**: do code analysis to obtain predicates from the hpc app code 
. what other things can be obtained in this way that a declarative 
interface provides?

# python

phytran compiles python to openmp.

**idea**: parse python to ceph

11/19

# Clarisse

Cross layer abstractions and runtime for storage I/o stack

Cifts or Argo will be used as the backplane control

Their approach is that they want to modify apps as lesss as possible

I/o flow . software defined storage from msr

Ff, Siox and Argo share some goals with Clarisse

11/20

# ACR automatic checkpoint restart

 - based on charm++
 - since charm++ is object-oriented, fault-tolerance is "hidden" from 
   the user
 - they handle silent data corruption and hard errors
 - the user specifies when an iteration is over
 - use replication
 - they use some type of consensus to decide when to checkpoint
 - they use checksums to identify failures

**idea**: need to read the paper, I arrived late to the talk and 
couldn't appreciate the work. One alternative without reading the 
paper is how could we apply what they're doing

# spbc 

- goals: low-overhead  for failure-free
- coodinated checkpointing: plain checkpoint/restart
- message-logging: log everything thus a single process can recover
- hybrid: multi-level checkpointing, why?

- they present a new protocol (scalable pattern-based checkpointing)
- channel-determinism: the relative order of messages has no impact on 
  content and order of messages sent by processes
- master-workers aplications don't comply with the above determinism
- for apps that are still considered from above, they don't support 
  apps using MPI_ANY_SOURCE type of messages
- they log inter-cluster messages
- they maintain "happened-before" relations, i.e. by logging 
  inter-cluster messges (the fact that a messge went from a cluster to 
  other), this holds.
- they add markers in order to deal with apps using MPI_ANY_SOURCE 
  apps

q:
- how can the user identify if his/her application is channel 
  deterministic? This is the main drawback I see.

**ideas**:
- it's becoming clear that existing approaches don't view failure 
  recovery from the point of view of the storage. Something I just 
  realized is that the main motivation might be that the data is not 
  the only thing that matters. Applications also have state at each 
  node. This has to be logged too.
- the experimental results for "performance during recovery" are what 
  we should do, i.e. the baseline is the failure free execution. We 
  want to spend as less time as possible w.r.t. the failure-free app.

# simulating kv stores to evaluate its usage in HPC

# exascale fault-tolerance panel

- loca dynamic checkpoint recovery
- main consensus: combination of all approaches is the way to go

# exascale io workgroup

- ROOT is used at CERN (object-oriented framework; seems similar to 
  charm+)
- xyratex's clovis is like IOD

11/21

# faults in dram (nvidia)

- cielo and jaguar (ddr-3 and ddr-2 respectively)
- faults decrease as the system ages
- they do a per-vendor study

# deadlock detection in MPI http://dx.doi.org/10.1145/2503210.2503237

- the MPI standard doesn't define a way of effectively using 
  communicate primitives. that is, if not used correctly, the 
  application can crash, provide incorrect results, hang due to a 
  deadlock, or event silently continue without any symptom
- there are tools to detect errors at runtime. existing deadlock 
  detection don't provide all characteristics desired by the authors
- these guys are doing a deadlock detection in a new way that other 
  tools hadn't done it before.

# openflow

- caltech
- olimps opwnflow controller  based in floodlight
- monalisa monitoring
- multipath forwarding
- use the topology discovery
- they load balance flows
- experiments zipf distributed of file sizes from 1 to 40 gbs and 
  500gb in total over 5 link multi paths
- avior GUI that NERSC implemented
