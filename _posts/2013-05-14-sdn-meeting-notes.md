---
layout: post
title: SDN - Meeting Notes
category: labnotebook
tags:
  - sdn
  - end-to-end-resource-management
  - sdn-for-storage
  - minutes
---

# {{ page.title }}

We have a little bit more of insight about the QoS state-of-the-art done on top of OpenFlow. Next 
steps:

  - look at how to get admission control working based on W'13 Lincoln's work.
      - determine if Lincoln's data is enough to maintain QoS state
      - if that's not enough to get us started then we need to figure out what's needed. In a 
        high-level, we need a way of either querying the switches from the controllers or determine 
        if the controller can get that info from the regular communication that happens between POX 
        and the switches to do the regular L2_learning switching.
      - use Floodlight's Dijkstra
      - simulate the Heitas cluster (fat tree topology)
      - we should get many alternative paths for any given flow
  - to-read (in order of importance):
      - distributed systems aspects of OF
          - [@koponen_onix_2010]
          - [@reitblatt_abstractions_2012]
      - QoS:
          - [@curtis_devoflow_2011]
          - [@wilson_better_2011]
          - [@hong_finishing_2012]
  - another alternative that we might consider is to replicate the experiments from 
    [@kim_automated_2010] to have a QoS end-to-end experimental platform up and running.

# References
