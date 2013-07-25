---
layout: post
title: SDN for storage - Mininet topologies
category: labnotebook
tags:
  - end-to-end-resource-management
  - sdn
  - sdn-for-storage
---

# {{ page.title }}

> **tl;dr:** Very basic notes on what mininet's topology mean. To the experienced networking person, 
they may seem stupid. I'm in **_undusting mode_** and this is the fastest way I've found to learn 
things (please read the [Why a Labnetbook for CS][lnb] entry).

In [Mininet][mn], one can specify the topology of the network through the `--topology` command line 
argument. According to [Wikipedia][w], there are two types of topologies, physical and logical. The 
physical topology is dictated by how the wiring is done, in terms of cables, switches, hubs, etc. 
The logical is how the nodes in the network communicate to each other (one could have a logical 
topology over a different physical topology). The main categories are:

  * Point-to-point
  * Bus
  * Star
  * Ring or circular
  * Mesh
  * Tree
  * Hybrid
  * Daisy chain

As mentioned before, the above applies to both physical or logical arrangements. From the cited 
Wikipedia article:

> The logical classification of network topologies generally follows the same classifications as 
those in the physical classifications of network topologies but describes the path that the data 
takes between nodes being used as opposed to the actual physical connections between nodes. The 
logical topologies are generally determined by network protocols as opposed to being determined by 
the physical layout of cables, wires, and network devices or by the flow of the electrical signals, 
although in many cases the paths that the electrical signals take between nodes may closely match 
the logical flow of data, hence the convention of using the terms logical topology and signal 
topology interchangeably.

Thus the main question is: what does the `--topology` argument specifies in mininet? Since Mininet 
(more precisely, [OpenFlow][of]) works at the [Control plane][cp] (by modifying entries in [Data 
Plane][dp] level[^1]), it means that this applies to the logical topology (how the packets get sent 
in the network). From the cited article:

> Most commonly, [the data plane] refers to a table in which the router looks up the destination 
address of the incoming packet and retrieves the information necessary to determine the path from 
the receiving element, through the internal forwarding fabric of the router, and to the proper 
outgoing interface(s). The IP Multimedia Subsystem architecture uses the term transport plane to 
describe a function roughly equivalent to the routing control plane.

Thus, what Mininet does is to provide a virtual network in which one can setup OpenFlow on top, and 
thus define new routing algorithms on the virtualized (logical) topology. The physical topology in 
Mininet, AFAIK, is assumed to be anything that supports TCP/IP[^2], although I'm not sure about 
this. Ultimately, this shouldn't matter since that's the whole purpose of [OpenFlow][of]. This is, 
of course, stupidly obvious[^3], since OpenFlow can't rearrange the hardware[^4].

[^1]: From this [tutorial slides][ts]: "OpenFlow is just a forwarding table management protocol"

[^2]: The main reason for implying this is that mininet deploys a TCP/IP network. But other types of 
physical arrangements work below TCP/IP (since that's the physical layer).

[^3]: Obvious not until I wrote it down. So +1 for the [labnotebook][lnb] approach :)

[^4]: Unless there's a robotic [SDN][sdn] that changes the physical arrangement of the network.

[mn]: http://mininet.github.io/
[w]: http://en.wikipedia.org/wiki/Network_topology
[lnb]: {% post_url 2013-06-30-blog-lab-notebook-for-cs %}
[sdn]: http://en.wikipedia.org/wiki/Software-defined_networking
[dp]: http://en.wikipedia.org/wiki/Data_plane
[of]: http://openflow.org
[ts]: http://www.stanford.edu/~brandonh/ONS/OpenFlowTutorial_ONS_Heller.pdf
[cp]: http://en.wikipedia.org/wiki/Control_plane
