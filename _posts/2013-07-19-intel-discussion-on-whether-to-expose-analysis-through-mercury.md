---
layout: post
title: Intel - Discussion on Whether to Expose Analysis Shipping Through Mercury
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

**Jerome**:

> If the analysis runs on the ION I don't really see a reason for using mercury as we are already on 
the server.

**Ivo**:

> But how does the simulation app (or scientist on her workstation) send the analysis in the first 
place? Somewhere in the stack, there has to be a function that allows the user/app to ship the 
analysis. Since the IOD instance is owned by the VOL plugin, I think we would benefit from having it 
being invoked as any other call (i.e. through mercury). Otherwise, if we have a standalone analysis 
server, we will have to deal with more complex issues (eg. since an external process can see only 
DAOS containers, how can we access the in-transit data that sits in the BB, without having the 
access to the server-side VOL plugin?).

**Jerome**:

> Well there are many ways of sending that, especially if we are building on top of python. In a 
typical in-situ scenario, analysis server are provided with the script and execute it every time 
(depending on the control we add and the loop we define) a new time step is written or new data 
comes in.
>
> To be honest I think that if we want we can have everything collocated,
then the analysis server is just another thread running, but then again
we are free of choosing another approach.

**Ivo**:

> The main restriction that forces us to have to talk through mercury (someone will correct me if 
I'm wrong) is the fact that an IOD instance is only visible to the process that "opened it". In 
order to be able to access data sitting on BBs, the server-side IOD stack instance has to be the one 
that access it, which in turn implies talking to the server-side VOL plugin process.
>
> This is (I think) due to the transactional features of the stack. If two entities are concurrently 
issuing transactions separately through distinct server-side VOL processes, there has to be 
coordination between them. This has an implication that goes all the way down to DAOS, i.e. two DAOS 
containers can't be shared (for read/write purposes) by two separate IOD instances. Having a 
read-only IOD instance accessing a previous DAOS version limits the usefulness of the analysis, i.e. 
in-transit data is not accessible. On the other hand, having read/write capabilities from other IOD 
instance would be too complex to implement.
>
> So I agree with your last point that having all collocated in the same software stack is the 
easiest thing to do. I think we should (at least initially) treat it as a special type of `H5_*_ff` 
call, one that triggers an MPI coordination routine on the IONs.
