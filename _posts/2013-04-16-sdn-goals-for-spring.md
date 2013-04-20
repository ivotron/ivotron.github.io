---
layout: post
title: SDN - Goals for Spring '13
category: labnotebook
tags:
  - end-to-end-resource-management
  - sdn
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
    the current statistics that we get from the switches.

  - initially we could define very simple routes that allow to have a simple logic for figuring out 
    the capability that each route has. May be a single rout for each two end-points.
