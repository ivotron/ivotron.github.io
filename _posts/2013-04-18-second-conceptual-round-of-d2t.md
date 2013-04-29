---
layout: post
title: Second Round of Thoughts on D2T and Integrated Application Workflows
category: labnotebook
tags:
  - hpc
  - d2t
  - transactional-storage
  - txn
---

been struggling trying to install the D2T build dependencies (trilinos/trios). I think I'll be able 
to finish the setup before our next meeting.

On the conceptual front, I feel more comfortable categorizing D2T as two chained 2PC processes. I 
was trying to force it into a single process but that wouldn't fit well into existing frameworks. 
2PC is very strict and thus has high overhead. So IMO we have to find a way of relaxing the 
semantics but in a principled way so that we don't end up guessing.

An alternative of doing this is HATs [@bailis_hat_2013]. I was talking to Joe Hellerstein and Peter 
Bailis yesterday about the assumptions they make, trying to identify if they would apply to our use 
case. Their key realization is that, by carefully implementing client/server caching logic, the need 
for centralized  coordination is gone. They achieve repeatable read, as well as read uncommitted 
isolation (this comes from the SQL lingo). Any of these could be enough for our scenario, so HATs 
could be our first attempt at relaxing D2T. I'll keep looking at this and will try to explain it 
better on our next meeting.

Another approach is to begin from a less restrictive scenario (such as FastForward's IOD semantics) 
and see how stronger we need to get in order to satisfy the requirements. I'm still not able to 
characterize precisely what these are, given my lack of experience with HPC workloads. Is there any 
paper that describes in more detail what CTH shock physics does in terms of I/O. Adaptive Mesh 
Refinement was mentioned in the context of Fast Forward, is this also good use case to look at? Any 
references on this would help a lot.

# References
