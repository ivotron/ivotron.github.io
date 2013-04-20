---
layout: post
title: Deploying Impala for Development
category: blog
tags:
  - bigdata
  - impala
  - development
  - configuration
---

# {{ page.title }}

> **tl;dr:** I describe how to deploy Impala and setup a development environment so that one can 
quickly push the changes done and test.

Impala dependencies:

  - HDFS
  - Hive

Impala reads metadata from Hive's metadata store (an RDBMS). So, in order to get this stuff running:

 1. install impala using cloudera manager
 2. deploy the impala binaries manually

The impala binaries are:

 1. `impalad`
 2. `statestore`
