---
layout: post
title: Review of Parallel Programming Fundamentals
category: labnotebook
tags:
  - txn
  - hpc
  - mpi
  - parallel-programming
---

# {{ page.title }}

I've been catching up with parallel programming concepts. I read chapter 1 and skimmed chapter 2 of 
[@pacheco_introduction_2011]. The conceptual presentation is extremely useful, specially on chapter 
2 when it talks about many parallel processing hardware and software topics.

One main concept was [Flynn's taxonomy][flynn]. This because Jay's code can run only if I activate 
MPI's MPMD mode. I also had to un-dust basic OS virtualization concepts:

  - [anatomy of a program in memory][antomy]
  - [Introductory chapter to Three Easy Pieces book][tep]
  - [Linux API book][lapi]

I've started to write a

[flynn]: http://en.wikipedia.org/wiki/Flynn's_taxonomy
[antomy]: http://duartes.org/gustavo/blog/post/anatomy-of-a-program-in-memory
[tep]: http://pages.cs.wisc.edu/~remzi/OSTEP/
[lapi]: http://shop.oreilly.com/product/9781593272203.do
