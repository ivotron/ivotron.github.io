---
layout: post
title: Intel - Skeletal Organization For Analysis Shipping
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

This is a follow-up to the [pseudo-code][pc] entry.

The following is a high-level description of the path an analysis shipping call takes:

 1. `H5FFpublic.h` and `H5FF.c` will expose the shipping functionality to apps. This will invoke 
    functions defined in the VOL IOD extension (`H5VLiod.h` and `H5VLiod.c`)

 2. The IOD VOL code (`H5VLiod.h` and `H5VLiod.c`) will contain the code that actually makes the 
    mercury calls and ships the analysis. This skips the client-side VOL calls since this is not 
    part of the VOL API.

 3. On the server-side, the IOD VOL code will contain the invocation to the H5AS extensions 
    (`HASpublic.h` and `HAS.c` will contain the MPI-based coordination). That is, the server-side 
    VOL code is just a hook through which we "hang" the shipping functionality to the server-side 
    process.

 4. The call gets coordinated/executed by the H5AS extension and it returns.

This is a very primitive server-side skeletal implementation (just prints to stdout when things 
should be actually invoked, kind of like the way IOD is currently "implemented"). My idea is to keep 
iterating, adding functionality/tests on each cycle. I think next immediate steps could be:

 1. Implementation of a hard-coded `H5VCreate`, i.e. won't actually execute any query but a 
    predefined one
 2. Implement `H5Vget_elem_regions`, so that each worker is able to iterate on a view

And later we can choose among the following:

  * Implement `H5Vcreate` properly so that it invokes local VOL calls

or:

  * Implement `H5Qcreate`
  * Extend `H5Vcreate` so that it reads the content of a query

or:

  * Implement `H5Qcombine`

or:

  * Integrate the Python runtime.
  * Wrap `H5View` objects around as `NumPy` arrays
  * Expose

or:

  * Allow writing to a dataset from python (wrap `H5Dwrite_ff` calls as NumPy array assignment).

or:

  * Define `H5ASAnalysis_task` structure
  * Implement `H5AScreate` function
  * Create encoding/decoding function for `H5ASAnalysis_task`
  * Allow clients to ship an analysis task

Regarding the other issues, I'd like to present some ideas I have on how to handle domain 
decomposition and block/chunk/slab assignment as part of the querying specification. Will do it on 
Thursday 3CDT?

[pc]: {% post_url 2013-08-07-intel-pseudo-code-for-simple-use-case %}
