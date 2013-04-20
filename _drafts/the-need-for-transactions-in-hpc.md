---
layout: post
title: The need for Transactions in HPC
category: labnotebook
tags:
  - dtm
  - hpc
  - transactional-memory
  - d2t
  - transactional-storage
  - research-ideas
---

Carlos replied to the question of whether or not ACID is required in an exascale scenario:

> Data almost never gets modified once written. The only coordination we need is between simulation 
applications (the ones that produce or consume checkpoints) and analysis applications (the ones that 
consume checkpoints and produce auxiliary data such as indices and products such as visualizations). 

Questions:

  - would something like independent transactions work
