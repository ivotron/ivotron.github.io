---
layout: post
title: Intel - Discussion on Analysis task coordination
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

**Jerome**:

I think that [this video][v] explains why I do not really want to support a socket connection 
between a workstation and the analysis servers for now (even it would be fine for testing but should 
not be part of the design).

I think we should not need that because VisIt or ParaView or the existing parallel analysis 
frameworks already rely on a client/server model where there is a GUI running on the desktop machine 
or workstation and the analysis servers running in parallel using MPI on the analysis cluster (or 
compute nodes or analysis nodes or whatever). I think that if we support that connection we would 
just duplicate the work in the sense that higher level analysis libraries don’t really need to use 
that since they already have their transport layer to communicate to the analysis servers. So 
probably we should not use mercury at all to send the analysis to the analysis server but rather 
have the analysis servers be able to use parallel scripting (with mpi4py etc) for example or things 
like that in a first time where we can show that we can do analysis on the ION and get results from 
the stuff that is stored in IOD/DAOS. Then depending on what the higher level analysis application 
will be, we should see how we integrate our library and the analysis extensions + python wrappers 
into it and how they already use their application in parallel and control it from a workstation (if 
I assume that the analysis application is not a well know application like paraview or visit). Does 
it sound reasonable?

**Ivo**:

The nice thing of the approach we are proposing is that it leaves this option as an orthogonal 
issue: if we need to expose an analysis server through IPv4/6, we can have it accept connections on 
this type of interconnect and then execute internal calls through mercury.

On a related note, I'm not sure what's the role of AXE here, but it might also be important to be 
able to take advantage of the async features. This is something I've been trying to figure out. 
AFAIK, if we go through mercury that means we will be enqueueing analysis tasks in the similar way 
that other VOL calls are, right? If we don't expose this through mercury, would we be able to also 
run the analysis job asynchronously?

On the other hand, IMO we shouldn't be thinking on how the EFF will adapt to fit current workbench 
frameworks. Instead, I would expect existing tools to write plugins for exa-scale systems such as 
the FF stack. An example of this is contained in [@rynge_enabling_2012], where they are able to plug 
Pegasus to a Cray XT5 system. I think it'll be easier for them to adapt to EFF than for us to target 
their use case. Just my 2c

**Ivo (follow-up):**

After re-reading your message, I think I initially didn't get your point.

What you're suggesting is not to coordinate the analysis task (i.e. don't worry about parallelizing 
the execution), but just allow tools to plug individually on each node, allow them to run their 
scripts locally and then let them do whatever coordination they're currently using, right?

I think this might work but up to a certain degree. Since EFF is not a regular parallel file system, 
there is semantic knowledge that an implementation has to be aware of (eg. sharding, replication, 
asynchrony, transactions, etc). This means that in order to plug existing tools on EFF at a lower 
level, there has to be some piece of code that is EFF-aware.

Given the above, I think the last point on my previous message is still valid. It is easier for 
existing tools to plug at a higher-level than a lower one, since the latter means that they would 
need to be aware of many things on EFF that they might not want to. I guess it would be a matter of 
choice.

Is also harder to demo the analysis shipping without having an AE coordinator. This could be 
implemented just for the demo, as you mention.

[v]: http://www.youtube.com/watch?v=ei_pFi2xOUc
