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

# Meeting Notes

  - we went over Spring '13 goals again and talked about possible conferences:
      - can we get net logs from Cisco that are tagged with app-specific metadata. arrival rate, 
        etc.?
      - can we capture the statistics of this from the switches that are part of the open flow 
        network?
      - create a controller that is able to tell you what are the capabilities of each route, based 
        on the current statistics that we get from the switches. The basic question is: can we know 
        what are the current capabilities of a route?
      - initially we could define very simple routes that allow to have a simple logic for figuring 
        out the capability that each route has. May be a single rout for each two end-points.

      - possible publication target is GLOBECOM '13 (poster), CLUSTER '13 (poster), FAST '14 (full 
        paper), or HPDC '13 (poster), SC '13 (poster). FAST would be a more complete paper. If we can 
        write a white paper (position paper) that can describe what Lincoln has been doing in mininet

  - briefly discussed traffic shaping (available in OpenFlow 1.3; but not in mininet 1.0, which is 
    what we're using). We commented that at this point we should start with something easier.

  - we discussed what level of detail of statistics we need to maintain. We convened that the link 
    capacity is enough:

        Controller

        link  capacity    utilization
        ---- ----------  -------------
          1
          2
          3
          4


    we can poll this from the switches. The main question is what level of detail this type of 
    statistics have and from those, what can we use.

  - Lincoln mentioned the work he did with Brad Smith on an algorithm for routing based on the 
    presence of an "Oracle", which in this case can be the controller. This might be used to derive 
    some sort of base-line to our reservation-based approach

# Next:

  - understand the APIs of OpenFlow, mininet and POX. The goal is get a clear understanding of how 
    they interact together.
  - figure out how to extract (at the controller) statistics from the switch
  - read RAD-flows paper
