---
layout: post
title: RADOS baseline
category: labnotebook
tags:
  - cephforhpc
  - cephforhpc-exp3
  - msst14
  - phdthesis
  - rados
---

In relation to what we discussed [yesterday] (seeing a lot of variance 
in our measurements and not achieving the 500 MB/s theoretical 
throughput), I followed Noah's advice and started to experiment with 
Ceph's `rados bench` utility. I've added a tab to the sheet I shared 
previously

Results are in [gdoc]

I first experimented with up to 8 clients each running 4 threads. 
The`many_clients` section of the sheet has a "time to stabilize" 
column that shows the time it takes to get to the point where the 
difference among entries in the raw records (contiguous per-second 
measurement) is +/- 2 MB/s, i.e. something that yields a small stdev. 
Before rados bench stabilizes, the differences among records is 
relatively big, all writers begin to write at 110MB/s and start to go 
down until they reach the avg throughput. This is the main reason why 
we see a lot of variance in our IOR/IOD experimental results. The peak 
throughput is achieved at 5 clients (225 MB/s)

The reason of this behavior is the following. A single rados bench 
client can get to 16 threads without experimenting issues in terms of 
throughput, so, if we add another client, the throughput should double 
(200 MB/s) and so on with a third up to 5 clients. I've verified the 
network by running netcat concurrently on multiple nodes (6 pairs of 
nodes) and I see 118 MB/s throughput, so, in theory, for 5 storage 
nodes (with 2 OSDs each), ~500 MB/s should be our theoretical 
throughput (assuming OSDs can keep with it).

The problem is that the journal absorbs the streams of I/O but 
eventually gets saturated and is nicely described in this 
[conversation][mail]:

> if you have a 1GB journal that writes at 200MB/s and a backing disk 
that writes at 100MB/s, and you then push 200MB/s through long enough 
that the journal fills up, then you will slow down to writing at 
100MB/s because that's as fast as Ceph can fill up the backing store, 
and the journal is no longer buffering.

To know more about how the SSD/HDD combo works, check [here].

---------

So, based on the above, I decided to get the less noisy baseline and 
go with the degree of concurrency that can be well served by the SSD 
journals. The "few_clients" part of the spreadsheet contains that. In 
summary, we will pick 1-8 clients in 4 nodes.

[yesterday]: {% post_url 2014-02-05-cephforhpc-mode4-second-round %}
[here]: http://www.sebastien-han.fr/blog/2013/12/02/ceph-performance-interesting-things-going-on/
[gdoc]: https://docs.google.com/spreadsheet/ccc?key=0AnohAxx-m2sQdE1zZFZLNGJxMXB6R1UwQldzaEk5Mmc&usp=sharing
[mail]: http://comments.gmane.org/gmane.comp.file-systems.ceph.devel/10021
