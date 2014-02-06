---
layout: post
title: Notes on IOD design
category: labnotebook
tags:
  - cephforhpc
  - iod
  - fastforward
  - meeting-notes
---

This are my ongoing notes on stuff I stumble upon while implementing 
the IOD interface on top of RADOS:

# comments

 1. There is no IOD client. The prototype assumes that a higher-level 
    layer is in charge of shipping IOD calls to the IO nodes. In the 
    current prototype, this make the use of HDF5 necessary.

 2. OID is the main handle, object name is metadata for objects. 
    Instead of having the option of assigning OIDs by IOD vs. clients, 
    pick a deterministic function that maps from names to OIDs (which 
    internally maps from name to a particular ION, like in Ceph, where 
    an infinite but totally ordered namespace is convened and 
    predefined). This is evident when a container has been closed. In 
    order to obtain IODs, the user has to list the contents of the 
    container, then obtain the OID corresponding to the name of the 
    object it wants to read and then use the OID to 
    open_write/open_read.

 3. name is the main ID for containers, which is confusing since for 
    objects the numerical identifier is the ID.

 3. API doesn't specify failure conditions in some places:

      * what happens when `iod_obj_create` is invoked over an existing 
        object. Should this fail?

 4. container "open" will implicitly create a container whereas an 
    object has to be created first. This is contradictory from the 
    user's perspective.

# questions

 1. what's the rationale behind I/O fragments?

