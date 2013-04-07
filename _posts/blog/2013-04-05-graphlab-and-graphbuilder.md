---
layout: post
title: GraphLab and GraphBuilder
category: blog
tags:
  - bigdata
  - graphlab
  - graphbuilder
---

# {{ page.title }}

In 2010, Google published Pregel [@malewicz_pregel_2010], a [BSP-based][bsp] 
[@valiant_bridging_1990] graph processing engine, also referred to as a vertex-centric approach (as 
opposed to [edge-centric][graph-computing]). [Giraph][giraph] is a library that mimics Pregel by 
running on top of Hadoop MapReduce.

An alternative to Giraph is GraphLab [@low_distributed_2012], another vertex-centric implementation 
part of the [Post-MapReduce era][postmr]. It has its own execution engine and operates 
asynchronously on top of HDFS.

[GraphBuilder][graphbuilder] [@willke_graphbuilderscalable_2012], as the name implies, is a set of 
MapReduce tasks that extract, normalize, partition and serialize a graph out of unstructured data, 
and writes graph-specific formats into HDFS. It is designed to produce the input to batch-oriented 
graph-processing frameworks such as GraphLab..

![][arch]

<!--
    todo
    The above is the architecture.
  -->

# References

[bsp]: http://en.wikipedia.org/wiki/Bulk_synchronous_parallel
[giraph]: http://incubator.apache.org/giraph/
[graph-computing]: http://markorodriguez.com/2013/01/09/on-graph-computing/
[arch]: /images/2013-04-05-graphlab-and-graphbuilder.png
[postmr]: {% post_url 2013-04-12-the-post-mapreduce-era %}