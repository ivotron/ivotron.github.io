<!--
---
layout: post
title: ISSDM Project Summary
category: labnotebook
tags:
  - ff
  - hpc
  - transactional-storage
  - issdm
  - project-description
---

# {{ page.title }}

% ISSDM Project Summary
% Ivo Jimenez
% May 15th, 2013
-->

**Abstract**. The road to exascale computing is well underway. Current predictions estimate that 
2018 will be the year of exascale, with millions of compute nodes and billions of threads of
execution [@cappello_toward_2009]. Ongoing efforts propose a radical change in the storage I/O stack 
[@intel_scope_2012 ; @braam_exa-scale_2012]. Two key principles behind the design of these new 
systems are (1) asynchronous I/O and (2) transactional storage, both targeted at enabling high 
concurrency I/O capabilities. The implementation of these principles gives rise to new challenges 
that need to be addressed in order to satisfy the exascale requirements. In this project, we 
identify two of such new arising issues: transaction coordination and efficient I/O resource 
management at the network level.

# Transaction Coordination

New Exascale I/O stacks will expose transactional capabilities to user applications without imposing 
any constraints in the serializability of operations [@barton_lustre_2013]. For example, the Fast 
Forward IOD layer implements timestamp-ordering-based multi-version concurrency control 
[@reed_implementing_1983] by requiring every call to be associated with a transaction ID 
[@bent_milestone_2013]. The decision of how versions of a particular object interact among each 
other (eg. how new versions of an object are derived from committed transactions) is left to the 
application. Conceptually, a transactional system can be broken into three orthogonal pieces 
[@ozsu_principles_2011]: concurrency, reliability and replication control sub-components. Thus, from 
this conceptual point of view, new I/O storage stacks provide with distributed concurrency control 
primitives on top of which reliability and replication mechanisms can be built. This mirrors the way 
in which transactional systems are implemented [@sears_stasis_2010 ; @cowling_granola_2012 ; 
@bernstein_hyder-transactional_2011]: a central component guaranteeing (A)tomicity and (D)urability, 
with (C)onsistency and (I)solation built on top. In this project we look at the alternatives for 
providing transaction coordination (reliability control). Initially, we don't plan to deal with 
replication issues (eg. for high-availability or fault-tolerance), although we will keep it in our 
radar as we make progress in the transaction coordination front.

There is a large volume of of work in the topic of transaction coordination 
[@al-houmaily_atomic_2010], mainly in the context of relational databases, providing strong, 
serializable consistency. In our case, we are interested at looking at this from the point of view 
of scientific computing platforms, where the communication models are different (fast interconnects; 
collective I/O) and thus require to either adapt existing techniques [@hursey_log-scaling_2011] or 
even define new commit protocols.

Recent work has analyzed alternative ways of providing weaker isolation levels [@adya_weak_1999] in 
a distributed setting [@bailis_hat_2013-1], which could also be applied "as is" in a scientific 
computing scenario, or might require to be redefined. The principal issue underlying this problem is 
determining the type of coordination needed by an application, which is not an easy task 
[@hellerstein_consistency_2011]. Given our lack of domain knowledge about scientific workloads (we 
don't know about contention levels, access patterns, etc), we will find this empirically by 
implementing one or more atomic commit protocol alternatives and executing existing scientific 
workloads on them, with the goal of gaining insight into the isolation levels required by them.

Another area of interesting work is the analysis of the trade-offs between placing the I/O nodes in 
the same network where compute nodes reside (eg. infiniband), against having them on a slower, 
external communication channel (eg. 100Gbps ethernet). In order to do so, we have to identify the 
main differences among the two settings and determine the type of transaction coordination required 
on each, with the goal of optimizing performance. Lastly, a similar study is required but with 
regards to the type of storage technology used at the I/O layer (SSD vs. HDD), that is, we would 
like to determine what mechanisms are best suited to either technology (or even for hybrid 
configurations).


# Efficient I/O Resource Management Through SDN-based Quality of Service

Having asynchronous and concurrent capabilities at the I/O layer results in having tens or hundreds 
of jobs running in tandem. However, the I/O capabilities are finite and thus many different tasks 
will eventually end up competing for I/O resources. Since not all applications have the same 
priority, this resource contention will negatively impact the performance of time-sensitive 
applications. For example, in many scientific workloads the dumping of checkpoints has higher 
priority than analysis of obsolete data [^1]. Since over-provisioning at Exascale is not an option 
(mainly due to the energy requirements that this would imply), efficiently managing the resources of 
the I/O layer will be fundamental to achieving not only the required performance but correct 
management of concurrent jobs.

[^1]: Assume a simulation job A is producing a new checkpoint. An analysis job B might have read 
data that, at the time it began running, was the most up-to-date version of A. However, since 
process A is now ready to produce a new checkpoint, job B's working set is now be obsolete and 
should instead read the newest checkpoint. An alternative is to pause job B or assign less I/O 
resources to it, in order to make room for job A's checkpointing.

Current research in the area of Software Defined Networking (SDN) [@mckeown_openflow_2008] is 
looking at the problem of QoS in datacenters [@curtis_devoflow_2011]. Many of the design principles 
behind SDN can be transfered to high-performance interconnects [@wellbrock_new_2013]. Achieving QoS 
in an HPC setting is a challenging task for which we have identified two important problems: (1) 
devising QoS techniques suitable for the exa-scale requirements and (2) coordinating network changes 
in a consistent way.

Quality of service implemented in software-based, centralized controllers can potentially bring 
real-time optimization and satisfiability of hard constraints. In this project we plan to leverage 
the work done in our group [@pineiro_rad-flows_2011] in the context of real-time systems and apply 
it to the new emerging field of SDN-based QoS. With such a solution, the entire software stack (from 
application to network, passing through memory and CPU) could get hard performance guarantees, 
simplifying significantly the development of workload management.

A network operating under the SDN model runs a (logically) centralized controller that monitors the 
state of the network and reconfigures the switches dynamically. The process of transitioning from 
one configuration to the next one turns out to be a very similar to the one we have to solve for 
coordinating transactions at the exa-scale I/O layer. We plan to evaluate if the methods described 
in the previous section can be directly applied to the SDN-enabled HPC setting and, if needed, adapt 
or devise new ones.

# References
