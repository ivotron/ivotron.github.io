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

  - current stage: design. There are many things that aren't clear at this point in terms of the 
    analysis shipping ideas.

  - there are two alternatives for how the analysis shipping results will be exposed to the user. 
    One coming from Quincey; other from Eric. I couldn't understand well what the differences were 
    going to be.

  - questions at this point:

      - what would the contents of an H5V be? Ruth suggested to have the whole HDF5 file containing 
        the result of the query. In terms of the diagram that it's included in 
        [@koziol_milestone_2013-6], this would be be the whole hierarchy, or maybe just the path 
        that goes from the root to where the resulting values are.

      - how would a query be parallelized?

# Next Steps

  - look at the re-sharding options that IOD provides to see how a query can be parallelized
