---
layout: post
title: SDN - Notes on embrane Talk
category: labnotebook
tags:
  - sdn
  - end-to-end-resource-management
  - sdn-for-storage
---

# {{ page.title }}

Presentation on SDN, its origins, what Embrane does

## 5 embrane (high-level)

  - embrane's goal "the agile data center"
  - all components should be automated
  - this means software-based all over
  - at the beginning they we're avoiding L2
  - target: cloud-based providers (private and public)

## 7 embrane (tech-level)

  - purpose: overlay environments in order to leverage physical resources
  - L3-L7 level
  - on top of SDN (tangential to "traditional" SDN)
  - there could be isolated L2 environments
  - blueprints for network designs
  - they work with vmware, cloudstacks, etc.

## 9 before embrane (2008)

  - compute side: cloud environment will eventually win over physical (90% virtual; 10% physical)
  - nodes are connected to physical networks (no virtualization)
  - there's a layer that isolates the internals of the network (axis layer)
  - inside that network, there are many ways of optimizing the L2 layer (if hosts only deal with L3)
  - there were L3 layers that handled isolated L2 layers
  - some people want to push the L2 bondaries to the hosts
  - other people want to push it up out of the host (L2)
  - there are two main operators: Systems ops vs Net ops
  - the net was managed by a team that had control all the way down to the ethernet cable
  - all the policies were easy to apply, since they could have access controls policies or any other 
    ones and ensure that people to comply with it
  - sdn has changed the relationship between System ops vs net ops
  - services that embrane provides lands entirely on the networking side

## 11 then switch-inside-the-VM came

  - virtual switching moves logic to the OS (host side)
  - trunking (??)
  - who's managing the virtual switching? systems ops or net ops?
  - particular stuff on storage admins: traditionally the whole stack is managed by the storage ops
  - this is what started the whole SDN (from the presenter's point of view)
  - why: now the whole network is inside the host
  - there's tension between systems vs net ops (net ops don't want to manage VMWare vSwitches)
  - vSwitch is a trojan horse: you can do whatever you want with the whole stack, potentially 
    breaking any security policies that net ops have.

## 19 SDN

  - something had to be done to find a middle spot that wouldn't be as host-side-oriented as 
    per-vm-hypervisor vSwitch
  - that's where the whole SDN came into play

## 20 Layer 2 overlays

  - layer 2 overlays is whatever you can build that doesn't require a router in between
  -
