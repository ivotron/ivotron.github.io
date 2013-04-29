---
layout: post
title: SDN - Goals for Spring '13
category: labnotebook
tags:
  - sdn
  - end-to-end-resource-management
  - sdn-for-storage
---

# {{ page.title }}

Fundamental Questions:

  - How to measure capacity? (available capacity?)(route capacity?).
  - What does it mean that a route has 100% of its capacity allocated already?
  - What would it take to reason about the problem in terms of the RAD-flows framework
  - How to deal with bursty traffic?
  - How necessary is fairness?
  - How can we use shortest path or multi-path routing to increase throughput? (Jonathan Lim)

--------

For Spring '13:

  - can we get net logs from Cisco that are tagged with app-specific metadata. arrival rate, etc.?

  - can we capture the statistics of this from the switches that are part of the open flow network?

  - create a controller that is able to tell you what are the capabilities of each route, based on 
    the current statistics that we get from the switches. The basic question is: can we know what 
    are the current capabilities of a route?

  - initially we could define very simple routes that allow to have a simple logic for figuring out 
    the capability that each route has. May be a single rout for each two end-points.

  - possible publication target is GLOBECOM '13 (poster), CLUSTER '13 (poster), FAST '14 (full 
    paper), or HPDC '13 (poster), SC '13 (poster). FAST would be a more complete paper. If we can 
    write a white paper (position paper) that can describe what Lincoln has been doing in mininet
