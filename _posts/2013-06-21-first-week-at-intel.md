---
layout: post
title: Intel Internship - Scoping the project
category: labnotebook
tags:
  - intel
  - hdf5
---

# {{ page.title }}

This first week, besides spending three days dealing with corporate issues:

  - orientation day (Monday)
  - the order of my Mac got delayed (couldn't do anything on Tuesday)
  - I-9 setup (Wednesday)
  - setting up my Mac (Thursday)
  - reading (Fri-Sun)

Initially, Eric Barton mentioned the following (when we were arranging my interview with him for the 
internship):

> One of the features we're working on in the Fast Forward I/O stack is analysis shipping, where an
I/O intensive function (e.g. query) can run directly on the storage servers. We're aiming to
demonstrate this using HDF5 extensions that allow a parallel application running on the storage
servers to determine which parts of the input data are local to each process, parallelize the query
appropriately and return results as a list of references. The idea is that someone browsing an HDF5
file on a workstation can "analysis ship" a query to the storage servers and exploit the full I/O
bandwidth there.
>
> I'm intrigued that we could potentially extend this to provide a mapReduce
framework to simplify query writing and this might be an interesting topic for a summer internship.
It's still early in the FF project, so what I'd be looking for out of the internship would be
proposals for how a mapReduce framework for HDF5 might look and how it might integrate with the FF
I/O stack. As the prototype FF I/O stack comes together, we could then think about taking the work
forward.

Then, Quincey Koziol mentioned the following:

> Yes, I'd like to have Ivo look into how to apply the recent query/view/index API extensions 
(described in the design document I've attached) to our "analysis shipping" ideas.  However, I'm 
traveling today/tomorrow to get to the face-to-face in Leipzig, so I can't talk to him directly 
until Thursday, probably (and maybe not easily until next week).  I've attached the statement of 
work and solution architecture documents for him to look at, mainly for the (sketchy) ideas for 
analysis shipping that we've included there.

At this point I'm not clear what's the scope of the internship. Will keep reading the docs.

# Next steps

 - read docs that Quincey sent (HDF Group Q4 deliverables).
