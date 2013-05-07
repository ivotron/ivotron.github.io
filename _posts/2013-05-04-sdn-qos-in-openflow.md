---
layout: post
title: SDN - QoS in OpenFlow
category: labnotebook
tags:
  - sdn
  - end-to-end-resource-management
  - sdn-for-storage
  - qos
---

# {{ page.title }}

I found [@kim_automated_2010] which is AFAIK the first article on OpenFlow-based work on QoS. They 
describe nicely the high-level requirements for QoS:

  - QoS APIs
  - network state DB
  - flow specs (policies)
  - performance model

**APIs**. QoS facilities at the switch implement [rate limiting][rl]. Queueing-based rate limiters 
are available in [OpenVSwitch (1.1+)][ovs]. I'm not sure if this is something that is available in 
1.2 or 1.3, but having it in OvS is enough, at least initially (if we want to experiment with actual 
switches then we'd need to find more about this). In terms of controllers, this is available in 
[floodlight controller][fl] and also in [Nettle][nettle] [@voellmy_nettle_2010] (which is what it is 
used in [@ferguson_hierarchical_2012 ; @ferguson_participatory_2012]). I'm not sure if it's 
available in POX or Trema, I'll find out more about this soon.

**Net state DB**. The state DB includes network topology, active flows, performance requirements, 
and available resources in each switch.

**Flow specs and performance models**. These are the policies, where we would use something like 
RAD-flows.

----------------------

I also found

   http://pane.cs.brown.edu/

From their page:

> Example - Isolating Apache ZooKeeper traffic
>
> Apache ZooKeeper is a coordination service used at Twitter, Yahoo!, Netflix and elsewhere, where 
it fills a similar role to Google's Chubby service or Paxos quorums. During write operations, 
servers in the ZooKeeper ensemble must agree to commit each operation, a task which is sensitive to 
increased network latency. By augmenting ZooKeeper with support for PANE, and granting it the 
necessary authority, our PANE-enabled ZooKeeper can request guaranteed bandwidth for its traffic, 
which, in turn, leads to lower latency as flows do not compete in switch queues with other traffic.

Other use cases include Hadoop (where they reserve guaranteed bandwidth for the shuffle and output 
phases), as well as Ekiga, SSHGuard and others. They have many publications that might be of 
interest to us.

------------

I will present both [@kim_automated_2010] (along with [@ferguson_hierarchical_2012]) next Monday 
12:30 at our weekly our seminar.


[ovs]: http://openvswitch.org/support/config-cookbooks/qos-rate-limiting/
[fl]: http://www.youtube.com/watch?v=M03p8_hJxdc
[rl]: http://en.wikipedia.org/wiki/Rate_limiting
[nettle]: http://haskell.cs.yale.edu/nettle/
