---
layout: post
title: FF - DAMASC Meeting Notes
category: labnotebook
tags:
  - ff
  - transactional-storage
  - iod
  - fast-forward
  - hpc
  - minutes
---

# Questions

1.  What types of consistency semantics will be required for future
    applications?
    1.  What new app/middleware operations require transactions?
    2.  Who is anticipated to interface with a raw transactional API?
    3.  Applications, middleware, PLFS, analysis

    **Answer**: any checkpoint/restart workload that runs on current technology is what it's 
    envisioned as running on top of FF. The main difference is to run million (or even billion) 
    processes concurrently. Also, new types of software stacks such as HPX (there are 2-3 projects 
    competing at this level; DoE will pick the winner) that take full advantage of the asynchronous 
    features of FF will also run on top of it, with much tighter requirements, but categorically 
    similar (i.e. high-levels don't change).

2.  What is an end-to-end example of when “transaction” semantics are required?
    1.  Write-once checkpoint workloads?
    2.  Mixed R/W workloads (e.g. checkpoint + BB analysis)?

    **Answer**: see above.

3.  What is the detailed process of reading data that is involved in a transaction?

    1.  How do you determine what data is the current consistent set?
    2.  How do you determine when data is no longer valid?
        1.  What about data versioning such as from multiple outputs of the same data over the 
            lifetime of a simulation?
    3.  How are failures detected during a transaction?
    4.  Similarly, how do you coordinate when a transaction has transitioned to a `durable` state?
    5.  Who holds the global `latest_wrting`? I.e. after a transaction moves between states, is the 
        status collectively known by every ION. Is there a transaction coordinator?

    **Answer**: This is more or less similar to what latest IOD document [@bent_milestone_2013] 
    describes, in particular section 4.5.2. In short, there are two ways:

      - two ways: client- vs. server-side coordination.
      - client-side means synchronicity at the compute-node side (MPI_Bcast).
      - server-side means asynchronous access, through the count-based approach.
      - both methods have a coordinating leader that has the responsibility of deciding what is 
        committed and what's not.
      - coordinators are elected through a hashing-based technique (hash of container name)
      - coordinators keep track of the status of each transaction
      - in the above sense, coordinators are metadata servers that are
      - for FF project, there's no fault-tolerance planned for IOD. If coordinator fails, the entire 
        compute job fails and has to be restarted.
      - for FF, there's no planned

    In general, from what John Bent mentioned, they don't have any sophisticated method for 
    coordinating a transaction, either way (client- vs server-side) is leadership-based.

    **New Questions**:

      - if BB is on CN fabric, and is using atomic broadcasts, can we piggy back on those messages 
        and implement transactions on top of them?
      - how is it that server-side coordination enables asynchrony? We need to re-read the IOD 
        milestone docs to try to understand this.
      - others

4.  Are versions intended to be modifications of previous versions, or is each one expected to be 
    completely different and only logically related to previous versions?

    **Answer:** modifications of previous versions.

5.  Is anyone currently evaluating the performance of different design choices at the IOD level? Eg. 
    client- vs. server-side transaction coordination. 

    **Answer:** FF is only concerned with design, prototyping and functional correctness (unit 
    tests). Follow-up project will look at performance evaluation, etc.

6.  Eric Barton’s LUG 2013 talk referenced to a “Scalable server health & collectives” approach used 
    to communicate and manage group membership. Will this apply to DAOS nodes, IOD nodes or both? 

    **Answer:** only to DAOS, IONs are in the same fabric than CNs

7.  Is the reason to have a separation of IOD and DAOS mainly to remove the responsibility of the 
    user to have to directly specify what's on disk and what's on flash? If we could automatically 
    determine this (i.e. have a method to identify what goes to BB and what gets moved to DAOS), 
    would that matter to the CN-side if it’s being done by a single layer (instead of a stacked 
    one)?

    **Answer:** they don't care, as long as:
      - BB (IONs) is placed on the compute-side (same interconnect as CNs).
      - user doesn't have to directly specify which objects go where

# Ideas

Best approach to pitch ideas to LANL folks is to write down a paragraph with it and send it to 
Aaron, so that he can send that to the right people. For example, he's generally aware of what 
people are experts in what area. Aaron is our liaison into LANL and the HPC world, but his not a 
know-it all. So, things he won't be able to answer he can route them to the appropriate people.

SDNs:

  - compute node interconnects are proprietary
  - look at Portals, since that pretty much understood by industry

BB QoS:
  - Aaron mentioned they're interested on this

# post-meeting discussion

  - We have enough understanding of IOD
  - We can begin looking at the IOD<->DAOS part
  - try to anticipate the FF follow-up project (the one that is schedule to begin on right next to 
    FF, around early 2015), since that's where all the interesting research questions are going to 
    get asked. So in this sense, we have to try to ask the questions ourselves since they're not at 
    that point yet.
  - Interesting directions:
      - transaction coordination
      - merging IOD and DAOS on the same layer
      - resource management at the BB layer (how do we decide priorities when allocating IOD for 
        multiple compute/analysis jobs)
      - what kind of resharding/layout/transfer policies can we implement in such a way that 
        IOD<->DAOS transfers are as efficient as possible (in a scenario when we have multiple 
        readers/writers, i.e. many compute jobs, many analysis jobs).

# Next steps

  - understand DAOS layer
  - start looking at things through the Ceph eye
    - what changes do we need to implement in Ceph in order to implement IOD
    - same as above but for DAOS
  - come up with more detailed descriptions of concurrent scenarios where many compute/analysis 
    applications are making use of IOD. This with the intent of anticipating issues at a finer 
    granularity, eg. what type of contention do we expect under certain patterns of system load.

# References
