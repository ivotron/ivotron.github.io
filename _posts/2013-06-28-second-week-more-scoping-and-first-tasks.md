---
layout: post
title: Intel - First high-level tasks
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

I've been working on the to-dos I defined this week:

  - how does the entity diagram looks like?

    ![entity diagram][images/labnotebook/2013-06-29-entities.png]

  - how about in terms for running processes?

    ![entity diagram][images/labnotebook/2013-06-29-processes.png]

  - in the diagram there is an client-side IOD component and a server-side one. Who's responsible 
    for managing the context of the server-side one? **A**: the functiion shipper daemon

  - what's an ION? **A**: an ION is part of the infraestructure, that is, it's a box in the cluster 
    that it's responsible for doing i/o operations, regardless of where they come from and what app 
    generated it. I was thinking that this was a FF-specific thing, specifically, i thought it was 
    an object (in object oriented sense) from the IOD framework. This might be true (IOD might have 
    a piece of code specific for the ION) but it is not exclusive of the IOD, that is, the function 
    shipper runs on the io node, as well as the server-side VOL plugin code

  - what's the context in which user-defined code executes in? **A**: the  IOD doesn't provide any 
    object based model for extending storage, thus, this has to be implemented on top. I was under 
    the impressio  that at some point of the stack, there was going to be context in which user-code 
    would run. This is not the case, since IOD has a very specific semantics about what it can do 
    with the objects stored. If something like this is implemented, it will have to be done on top, 
    and in that sense the HDF guys are doing this: they are executing VOL on the server-side in the 
    contxt of the function shipper server-side daemon. This what it can be considered as the osd in 
    ceph

  - when shipping analysis scripts, what's the interface to it? **A**: Is it part of the HDF API or 
    is it only part of the Function Shipper one? as a consequence of the above, the "analysis 
    shipping" part of the hdf extensions won't be sending python scripts that are executed in a 
    server-side python runtime, rather, the analysis capability will get exposed by the hdf analysis 
    extensions that will be part of FF. Python scripts can be used but they will be sending HDF 
    objects, not python scripts. I was thinking this because of the way datamods implements this 
    scrioting shipping stuff.

  - there are HDF5Q V and X routines for doing the analysis, but there is no aggregation 
    functionality, i.e. no way of applying a function to the set of retrieved objects. Is this 
    something that would be implemented on the CNs? Or is it something that could be done on the ION 
    side but that it's not designed yet? This could be possible since IONs (as well as DAOS) have 
    compute capabilities. It would be cool to have the stack decide what can be executed in the ION 
    and ehat can be computed easily in DAOS. Are there plans to extend this to incorporate the 
    shipping of analysis functions, i.e. instead of having CNs compute the function, the IONs (or 
    DAOS nodes) would do it instead?

  - are there more details available on how H5Q*/H5V* routines will get executed? If a particular 
    query touches distinct partitions of a dataset (i.e. located in distinct nodes), how is that 
    going to be managed? I think they don't know yet and this is precisely the scope of the project. 
    I will be working on this in terms of design. This is inline to what Quincey mentioned 
    previously:

    > I think it would make sense to use the H5Q*() routines to define a query for the analysis 
    operation, then create a view with the H5V*() routines and then have a [set of?] callback 
    routine(s) in the application that gets invoked by an "iterate"-style routine in the H5V 
    interface, passing in pieces of HDF5 file information (links, attributes, data elements, etc) 
    for the application to look at and decide if it wanted to keep the information.  And, **the 
    analysis shipping component within HDF5 should divide up the HDF5 container, so that it can be 
    processed in parallel**. Not your typical MapReduce-style analysis, I don't think...

# Next Steps

  - take a simple analysis routine (eg. median over a range of values) and implement it in FF-HDF5. 
    Walk it through the stack. What happens if it touches data that sits in distinct partitions? How 
    does the VOL plugin handle this?
  - prepare questions for first meeting

implementation side:

  - setup a one-node dev/test environment
  - take a look at the FF-VOL implementation
  - start playing with it (run examples; write to log to see how this looks like)

publication:

  - begin writing an intro section
