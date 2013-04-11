---
layout: post
title: Fast-Forward on Ceph - Round 1
category: labnotebook
tags:
  - ceph
  - daos
  - hpc
  - fast-forward
---

# {{ page.title }}

> **tl;dr**: The [Fast-Forward I/O][ff-docs] project is divided in [five components][ff-intro], the 
last two (from a top-down point of view) being the DAOS and Storage layers. This post contains a 
first "round" on how these two layers could potentially be implemented on [Ceph](http://ceph.com). 
As I get more into the details of the DAOS/Storage layers, as well as how Ceph works (from the FF 
point of view) I'll have a better understanding. I'll post a "round 2" entry as soon as I feel that 
I have significantly advanced on what I'm describing here.

The components of DAOS are [@barton_milestone_2012]:

  - Storage targets
  - Objects
  - Transactions
  - Caches
  - Non-blocking interfaces

Let's go over each and speculate on how they could be implemented in Ceph.

## Storage Targets

OSDs. The hierarchy used to define the fault domains and resource contention can be handled by 
CRUSH.

## Container

As far as I can understand, a container is very similar to a pool, with the exception that POSIX 
`stat(2)` and `fstat(2)` aren't implemented in `librados` (but could easily be).

## Objects

It's my current understanding that this is almost exactly the same as Ceph's objects.

## Transactions

From Ceph's point of view, DAOS' transactions can be described as Consistent Snapshots. Currently, 
Ceph supports snapshots at the object-storage and POSIX-interface level. However, the snapshots 
aren't as strict as the 'epoch' concept contained in the DAOS proposal. From 
[Sage](http://ceph.com/dev-notes/rados-snapshots/):

> Map propagation is fast, but not synchronous: it is possible for one client to create a snapshot 
and for another client to then perform a write that does not preserve some data in the new snap. So 
we do not completely solve the synchronization problem for you to create a global, 'instantaneous' 
point-in-time snapshot. Doing so in a large distributed environment with many clients and many 
servers, operating in parallel, is a challenge in any system.

This means that 'transactions', as defined by DAOS would imply having read-consistent snapshots, so 
that whenever a new snapshot is created, the now-old snapshot can NOT be written on.

Another very important point is that the Storage layer will allow many versions to be written 
concurrently, regardless of their consistency and when the application "commits", the filesystem 
creates one. This is not possible currently in Ceph, since a snapshot is written "one-at-a-time".

## Caching

There is some current form of caching in `librados` that is snapshot-aware (since the snapshot IDs 
are part of the cluster map). However, with the addition of multiple concurrent snapshots, this 
would need to be extended.

## Non-blocking I/O

The mechanism for registering callbacks is not in Ceph, at least not at the level of a snapshot 
(transaction in DAOS lingo). There's a *watch* facility for object-level operations but I don't 
think it's robust enough to solve implement a solution for allowing all blocking operations to 
return immediately as proposed by DAOS

[ff-intro]: {% post_url 2013-04-07-the-ff-stack %}
[ff-docs]: https://wiki.hpdd.intel.com/display/PUB/Fast+Forward+Storage+and+IO+Program+Documents
