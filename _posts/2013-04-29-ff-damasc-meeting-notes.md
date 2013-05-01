---
layout: post
title: Damasc Meeting Notes - Performance of Reads
category: labnotebook
tags:
  - ff
  - hpc
  - transactional-storage
  - minutes
---

# {{ page.title }}

We summarized all our definitions/questions

# DEFINITIONS

1.  Container

    1.  This is a logical namespace that contains objects
    2.  It is tempting to relate this to pools in Ceph, but pools in Ceph have different purposes. I 
        think it better to assume that a container doesn’t exist in Ceph.

2.  Container shard

    1.  A partition of a container. Shard is a key term: the objects in a container are sharded over 
        a set of partitions.
    2.  Set of objects (simplistic definition just to talk about transactions)

3.  Transaction

    1.  A set of writes to a container that complete (or abort) together
    2.  A transaction is numerically labeled (e.g. 1337), and clients agree upon a label
    3.  Simple example

        - One million processes each perform some writes to a container as part of transaction 
          \#1337. The \#1337 label might be broadcast from rank 0 to the rest of the communicator

4.  Transaction consistency

    1.  There are two issues  (1) conflicting writes and (2) flattening
    2.  Clients handle intra-transaction conflicts themselves
        1.  Multi-writer/single object has undefined consistency semantics
        2.  Single writer has read-after-write consistency
    3.  Flattening applies writes in the order of transaction labels
        1.  This isn’t yet well defined

5.  [Consistent view][cv]


6.  Versioned reads

    1. Consistent view of container for a specified label (not “read from xtrans”)

7.  Function shipping

    1.  I/O forwarding
    2.  HDF5 IOD VOL says “The FS is general enough to allow its users to
        ship any type of operation and has a framework for extending the
        operations it supports.”

8.  Analysis shipping
    1.  Co-located data analysis

# QUESTIONS

See [this entry]({% post_url 2013-04-30-ff-issdm-meeting-notes %})

[cv]: {% post_url 2013-04-19-iod-as-we-understand-it %}
