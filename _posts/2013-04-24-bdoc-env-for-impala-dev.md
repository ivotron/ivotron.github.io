---
layout: post
title: Setting a DevEnv for Impala
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

I'm assuming Ubuntu 12.04 as the OS (I'm actually running on a single VM).

We have to achieve the following:

 1. install impala (and dependencies).
 2. configure impala to use the debug version
 3. compile Impala
 4. deploy binaries

# Install Impala and dependencies

Using [free cloudera manager][cdm] (I'm using 4.5.1) makes it easier. I installed it in a VM and 
picked OS packages instead of Cloudera's Parcels.

# Confiugre impala to use the debug version

In a terminal type:

```bash
sudo update-alternatives --config impala
```

and select debug as the default version. Restarting Impala through the manager is [easy][restart]. 
After this, the debug version should be running.

# Compile Impala

Follow [this guide][compile] in order to compile Impala. The compilation can be done either on the 
same machine where CDH manager is running or on an alternate one. If the latter, then the build 
dependencies must be installed on the machine running the CDH manager anyway (since that's what the 
compiled binaries expect). An alternative would be to generate static binaries but I didn't want to 
mess up with the `cmake` configuration.

# Deploy

Shutdown the impala service before transferring the binary files. The compiled binaries (w.r.t. 
impala root dev folder) are:

 1. `be/build/debug/service/impalad`
 2. `be/build/debug/service/libfesupport.so`
 3. `be/build/debug/statestore/statestored`
 4. `fe/target/impala-frontend-0.1-SNAPSHOT.jar`

1-3 must be copied to: `/usr/lib/impala/sbin-debug` while 4 resides in `/urs/lib/impala/lib/`

Start impala and you should be seeing your version.

[cdm]: https://ccp.cloudera.com/display/SUPPORT/Cloudera+Manager+Downloads
[restart]: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CM4Free/4.5.1/Cloudera-Manager-Free-Edition-User-Guide/cmfeug_topic_4.html
[compile]: {% post_url 2013-04-03-building-impala-on-ubuntu-12.04 %}
