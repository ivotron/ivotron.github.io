---
layout: post
title: SDN - Learning OpenFlow Concepts
category: labnotebook
tags:
  - sdn
  - end-to-end-resource-management
  - sdn-for-storage
---

# {{ page.title }}

I'm trying to learn the concepts first. This is what I've read so far:

  - relevant chapters from [this book](http://amzn.com/0132856204)
  - high-level description of the [network stack][net-stack]
  - the level at which OpenFlow [operates][openflow-level]
  - the [openflow tutorial][ts]
  - OpenFlow Switch Specification (0x01 protocol) [@openflow_switch_consortium_openflow_2009]

From the above I got:

 1. OpenFlow is a protocol for maintaining the routing tables of a network switch.
 2. When a packet arrives to an openflow-enabled switch, its header is compared against a set of 
    rules. If the rules applies, then the action defined for that rule is taken, if not, it is sent 
    to the controller in order for it to handle the packet.
 3. Many approaches exist in terms of how they can be categorized (from [the tutorial][ts]):
     - centralized vs. distributed (one vs. multiple controllers)
     - microflow vs. aggregated (rule-per-flow vs many-flows in one rule (pattern-matching))
     - reactive vs. proactive: first packet contacts controller to fillup tables or tables are 
       pre-filled
     - virtual vs. physical (not sure about this)
     - fully consistent vs eventually consistent

The OpenFlow switch has the following *Flow Table*:

    | Header Fields | Counters | Actions |

`Counters` specify which counters get modified after a rule matches. The `Actions` field contains 
the action to take. The fields look something like the following. A nice description is in Open 
flow's tutorial [@heller_openflow_2012] (slides 24-31):

![OpenFlow basics][basics]

For example, there might be rules like the following:

![OpenFlow sample rules][rules]

The first one is a generic pattern, so it might apply to many flows. The second one is a microflow 
that applies to a single flow (coming from an specific start-point). The third one is a 
firewall-like rule. Routing and VLAN rules are supported (i.e. interconnect networks).

The details of how the protocol works are in the spec [@openflow_switch_consortium_openflow_2009].

At this point, the concepts are clear, I know what OpenFlow is doing. Next step is to read the what 
are some of the APIs to openflow as implemented in controllers, specifically in POX:

   <https://openflow.stanford.edu/display/ONL/POX+Wiki#POXWiki-OpenFlowinPOX>

[net-stack]: http://en.wikipedia.org/wiki/Network_stack
[openflow-level]: {% post_url 2013-04-10-sdn-mininet-intro %}
[ts]: http://www.stanford.edu/~brandonh/ONS/OpenFlowTutorial_ONS_Heller.pdf]
[basics]: {{ site.url }}/images/2013-04-23-sdn-openflow-basics.png
[rules]: {{ site.url }}/images/2013-04-23-sdn-openflow-basics-rules.png
