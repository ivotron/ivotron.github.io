---
layout: post
title: Intel - Scoping the project 2
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

After going to the documents and getting to know what it's the state of the project, it looks like 
the scope of the project is the following:

  - currently, the focus is HDF5 extensions for the transactional capabilities
  - there are some rough ideas on how to implement analysis shipping routines (basically querying 
    and views (as well as indexing))
  - the above is accomplished by H5Q* and H5V* functions defined in [@koziol_milestone_2013-6].

After concluding the above and re-reading the messages that I got from Eric and Quincey, it seems 
that the scope of the project is:

  - take the high-level specs for H5Q*/H5V* functions, and see how can we implement an ION-side 
    analysis execution engine (in Python).

Then, yesterday Quincey emailed me the following:

> **me**: Is there any specific analysis shipping routine that you have in mind that exemplifies 
this feature? We could use the "traditional" word count or others from MapReduce, but I was 
wondering if there's something specific (ACG-specific maybe)?
>
> **quincey**: Eric & I have been talking about how this should work and we are still evolving the 
exact model...  :-/  I think it would make sense to use the H5Q*() routines to define a query for 
the analysis operation, then create a view with the H5V*() routines and then have a [set of?] 
callback routine(s) in the application that gets invoked by an "iterate"-style routine in the H5V 
interface, passing in pieces of HDF5 file information (links, attributes, data elements, etc) for 
the application to look at and decide if it wanted to keep the information.  And, the analysis 
shipping component within HDF5 should divide up the HDF5 container, so that it can be processed in 
parallel. Not your typical MapReduce-style analysis, I don't think...

And this is where everything clicked. It looks like I'm on the right track then.

# Next steps

Looks like the high-level steps for the internship will be:

  - review docs [@koziol_milestone_2013-6 ; @koziol_milestone_2013-7 ; @koziol_milestone_2013-8 ; 
    @koziol_milestone_2013-9 ; @koziol_milestone_2013-10 ; @koziol_milestone_2013-11 ]
  - draw the diagram of the stack, with all it's processes
  - take a simple analysis routine (eg. median over a range of values) and walk it through the stack
  - see how python scripts that use h5y look like
  - think about how to extend h5y to incorporate FF-extended HDF5
  - "implement" the simple analysis routine in FF-extended h5y

on the implementation side:

  - setup a one-node dev/test environment
  - implement h5y extensions
  - run examples

on publication side:

  - demo/workshop paper

# References

