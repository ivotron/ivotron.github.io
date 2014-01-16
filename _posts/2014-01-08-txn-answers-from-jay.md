---
layout: post
title: Feedback from Jay regarding ideas on async and concurrency coordination
category: labnotebook
tags:
  - txn
  - msst
  - experimental-plan
---

The issues:

  1. two or more nodes might write concurrently to the same object
    [^obj]
  2. async coordination, i.e. no need to target global coordination

[^obj]: object might be block, stripe, variable, slab, etc.


Jay's feedback:

  1. current schemes that rely on locking or optimistic coordination 
     assume POSIX. ADIOS and others solve this issue but treating 
     every rank's I/O independently. So no need to worry about this, 
     at least not yet.
  2. async coordination might not be needed at all, since d2t 
     experiments show a very low overhead.
