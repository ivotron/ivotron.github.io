---
layout: post
title: The Post-MapReduce era
category: blog
tags:
  - bigdata
  - mapreduce
  - hadoop
  - post-mapreduce
---

Due to the increasingly usage of high-level languages/frameworks that run on top of Hadoop...

thus, MapReduce, viewed from this point of view, turns out to be an execution engine, meaning it 
that Hadoop jobs are generated but not written directly. According to some figures, 95% of jobs are 
generated and not written directly.

Around 2008, people started to think in ways of optimizing this high-level frameworks by:

 1. improving mapreduce
 2. removing the Hadoop layer and executing on top of the HDFS.

Examples of projects in the first:

  - [@olston_automatic_2008] [@babu_towards_2010]
  - mapreduce online

Projects in the second camp:

  - [@behm_asterix_2011]
  - [@zaharia_resilient_2012]
  - [@melnik_dremel_2010]

Etc..

So, MapReduce will be relegated to the batch-processing niche and HDFS is what remains. Many people 
use Hadoop to refer to the Apache Bestiary, so it makes it necessary to qualify Hadoop MapReduce, 
Hadoop FS, etc..


<http://www.quora.com/What-are-paradigms-other-than-Map-Reduce-that-make-sense-to-support-in-Hadoop>
