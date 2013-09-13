---
layout: post
title: Intel - Meeting Notes
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

**atendees**: quincey, ruth, jerome

I presented [this slide deck][sd]

output of analysis:

  * a single dataset might not be enough to capture the output.
  * alternatively, we should let the analysis application execute whatever write calls it wants
  * so first thing that we should do is to wrap regular HDF5 calls in python and allow user to 
    execute whatever s/he wants

query-only tasks:

  * just pre-define the writing of the output to a container/dataset

server:

  * the `H5Vcreate` routine might need to execute calls that are not local to an ION, i.e. if it 
    needs to get KV pairs.
  * the first brute-force approach of executing regardless of whether is local is OK.

  * on a more "query optimizer"-like approach, the "prepare" phase (the first conditional of the 
    server-side pseudo-code) is where smart things should be done:
      * obtain the referenced objects
      * validate their references
      * query the layout of each object
      * possibly create "hints" that should be passed to each per-ION `H5Vcreate` call

python wrapper:

  * how do we wrap other stuff contained in the view? objects and attributes
  * how is each instance of the python analysis coordinating their writes (i.e. same issues with 
    writing from app running in CNs): overlap writes.

next steps:

  * focus on the second half of the analysis shipping to-dos:
      * integrate python
      * how to expose h5view objects
      * how are apps writing the output
      * etc

  * in other words, don't worry on the "talacha" stuff, focus on the meat

higher-level issues:

  * the examples show a bias towards the netcdf format. Need to figure out why and make changes so 
    that the example is more hdf-oriented
  * just give access to the mpi communicator to the apps and let them do whatever they want.

[sd]: {% post_url 2013-08-16-intel-analysis-shipping-implementation %}
