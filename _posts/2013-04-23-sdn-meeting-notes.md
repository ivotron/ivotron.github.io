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

  - we went over Spring '13 goals again and talked about possible conferences:

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

Next:

  - understand the APIs of OpenFlow, mininet and POX. The goal is get a clear understanding of how 
    they interact together.
  - figure out how to extract (at the controller) statistics from the switch
  - read RAD-flows paper
