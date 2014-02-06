---
layout: post
title: They day txn project died.
category: labnotebook
tags:
  - txn
  - msst
  - experimental-plan
---

> I've been finding more work on this topic (see below). Last 
reference gives an algorithm to find the optimal arity of a 
communication tree for collectives (eg. gather/broadcast). This shows 
how big is the impact of correctly placing processes (orders of 
magnitude in some cases). So in theory, D2T could perform even better. 
The Buntinas et al. protocol achieves dynamic consensus in 200 
microseconds on a BlueGene/P with 1,024 quad-core nodes, using 
unoptimized collectives. D2T on the other hand runs in 30000 
microseconds, so it's clear that there's still plenty of room for 
improvement. 

> I think all this is orthogonal to the MSST paper though. I fixed an 
issue I had on my code that resulted on skewed placement of processes, 
hence the strange results we were observing. I'm running the 
experiment again just to corroborate but I think we should move on 
w.r.t. this issue and focus on the sync/async stuff we discussed on 
our last meeting: using IOR, d2t and IOD-on-ceph as our experimental 
platform for the MSST paper.

> References [@chen_mpipp_2006 ; @jeannot_near-optimal_2010 ; 
@graham_cheetah_2011 ; @subramoni_design_2012 ; @jeannot_process_2013]

Based on my findings of my 01-15 notes, as well as the above, we 
decided to treat coordination as a given instead of trying to explore 
alternatives to existing work. So this effectively kills txn by 
having:

  * `MPI_Allreduce` as the primitive to do sync coordination
  * ignore failures, at least for now.
  *



