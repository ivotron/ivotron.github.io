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

**Attendees**: Jerome, Ruth, Quincey

We went over the analysis shipping architecture. We agreed on doing what I describe in [this doc][d]

Things that still aren't clear:

  - how do we expose the analysis shipping through a socket-based interconnect (IPv4/6)
  - how is data being written to disk?

# Next Steps

Write slides so that we:

 1. show test cases
 2. describe architecture
 3. show how test cases run in the proposed architecture

[d]: {% post_url 2013-07-18-intel-analysis-shipping-basics %}
