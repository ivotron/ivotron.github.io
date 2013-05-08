---
layout: post
title: TXN - Meeting Notes
category: labnotebook
tags:
  - txn
  - hpc
  - transactional-storage
  - minutes
---

# {{ page.title }}

My update:

  - finished with integration of redis-backed store into Jay's code. With the following missing 
    pieces:
      - implement a second md/ds server
      - double check the semantics of redis-backed store:
          - try by making original mpi-based md/ds work and then compare outputs
          - if above doesn't work, do it manually by reading the code.
      - write detailed description of `txn`
  - I've also written a small spec document that describes how to replicate FF's transactions.

Notes on discussion:

  - gave update on my current status
  - discussed the lack of specificity from FF docs and its transactions

Next steps:

  - work with Jay's 2PC as baseline, since there's nothing specified in FF
