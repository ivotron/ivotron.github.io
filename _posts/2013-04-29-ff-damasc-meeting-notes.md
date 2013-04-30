---
layout: post
title: Damasc Meeting Notes - Performance of Reads
category: labnotebook
tags:
  - ff
  - hpc
  - transactional-storage
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

## Transactions/Consistency (High-Level)

1.  What types of consistency semantics will be required for future
    applications?
    1.  What new app/middleware operations require transactions?

2.  Who is anticipated to interface with a raw transactional API?
    1.  Applications, middleware, PLFS, analysis

3.  What is an end-to-end example of when “transaction” semantics are
    required?
    1.  Write-once checkpoint workloads?
    2.  Mixed R/W workloads (e.g. checkpoint + BB analysis)?

4.  What is the detailed process of reading data that is involved in a
    transaction?

    1.  How do you determine what data is the current consistent set?
    2.  How do you determine when data is no longer valid?

        1.  What about data versioning such as from multiple outputs of the same
            data over the lifetime of a simulation?

    3.  How are failures detected during a transaction?

5.  Are versions intended to be modifications of previous versions, or
    is each one expected to be completely different and only logically
    related to previous versions?
6.  Is anyone currently evaluating the performance of different design
    choices at the IOD level? Eg. client- vs. server-side transaction
    coordination.
7.  Eric Barton’s LUG 2013 talk referenced to a “Scalable server health
    & collectives” approach used to communicate and manage group
    membership. Will this apply to DAOS nodes, IOD nodes or both?
8.  Is the reason to have a separation of IOD and DAOS mainly to remove
    the responsibility of the user to have to directly specify what's on
    disk and what's on flash? If we could automatically determine this
    (i.e. have a method to identify what goes to BB and what gets moved
    to DAOS), would that matter to the CN-side if it’s being done by a
    single layer (instead of a stacked one)?

[cv]: {% post_url 2013-04-19-iod-as-we-understand-it %}
