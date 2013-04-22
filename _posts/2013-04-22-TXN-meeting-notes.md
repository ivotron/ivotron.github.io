---
layout: post
title: Meeting Notes
category: labnotebook
tags:
  - hpc
  - d2t
  - transactional-storage
  - txn
---


  - current code has collective coordination on client-side, there is one global coordinator and 
    then sub-coordinators that handle the communication directly to the server side, that is, 
    there's no server-side coordination.

  - with regards to experiments, we want to have a point of comparison against other alternatives, 
    in particular with FF's epochs. Currently test code only has one single operation going on but 
    we want to create the infrastructure to run multiple transactions and be able to compare to the 
    epoch approach from fast-forward

  - Jay is considering a publishing a poster version that includes the current state (which has 
    significantly changed from the one presented in the D2T paper), as long as it wouldn't 
    invalidate a future publication

  - we might target HPDC or IPDPS '14, whose deadlines are around Jan/2014. Alternatively we could 
    submit something in September.

  - txn_test has write_test and update_test
     - writes to a data store and the metastore
     - update comes then reads metastore to see what can be updated,
       then it simulates stuff being updated and dumped and it completes
