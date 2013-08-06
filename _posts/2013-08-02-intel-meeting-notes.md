---
layout: post
title: Intel - Meeting Notes
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

Attendees: Quincey, Ruth and Jerome

I presented [Use Cases]({% post_url 2013-08-01-use-cases %})

Feedback follows.

# Use Case 1: simple query

It's not clear how the user will interact with H5View objects from the client. The main problem is 
that the client doesn't have the objects in its side in order to retrieve them. The view is pointing 
to the underlying objects but not the actual objects.

An alternative is to have query-only analysis tasks to dump their output to the output dataset.

# Use Case 2: Sort

We won't focus on this initially, so we can ignore it for now.

# Use Case 3 & 4

I explained the [concept of chunking]({% post_url 2013-07-30-intel-extended-use-case %}) and how it 
would be implemented by the user.

**Quincey**:
  - not a good idea to expose directly the MPI communicator
  - it would be better to do the decomposition and assignment on behalf of the user
  - an alternative would be to have two abstractions to let the user specify:
     1. what to do on what is local for an ION
     2. what to do to merge per-ION chunks
     3. how to merge globally

**Me**:
  - exposing an API that forces the user to think in terms of non-local vs. local is not so good 
    idea in my opinion
  - the functionality of decomposing the data has to sit somewhere, either on the user side or on 
    the analysis extensions side. What I got from Quincey is that he would like to have the latter

# Next steps

  - more detailed behavior of the h5view object. how are we going to read it? What about queries 
    without analysis?
