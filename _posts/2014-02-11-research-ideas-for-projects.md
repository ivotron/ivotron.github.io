---
layout: post
title: Ideas for research projects
category: labnotebook
tags:
  - ceph
  - research
  - ideas
  - brainstorming
---

In the same way that the DB community has used (and still uses) 
[postgres] as its experimental platform, I think Ceph is so generic 
and so well architectured that a lot of things can be experimented in 
it (all following ideas rely on this):

  * multi-client transactions on top of Ceph. Something like epochs or 
    dey et al. [@dey_scalable_2013].
  * bigTable on top of ceph. There's no way of distributing keys 
    across objects in ceph. We need an interface to mimic the tablet 
    servers of big table. a summer intern did [this][bt-ceph] but I 
    think it can be improved significantly
  * replacing leveldb with others. similar to what's being proposed 
    [here][kv-firefly].
  * many execution engines rely on having daemons "close to the data". 
    This is true for all the big data engines such as hadoop, impala, 
    spark, etc., which have java vm's running on each HDFS node. These 
    daemons understand what the data stored locally at those nodes is. 
    In Ceph, there's no way to abstract this. Ideally, we'd like 
    something like the object-level CLS modules, but at the OSD level 
    (or even placement group?).

[kv-firefly]: https://wiki.ceph.com/Planning/Blueprints/Firefly/osd:_new_key//value_backend)
[bt-ceph]: http://ceph.com/papers/CawthonKeyValueStore.pdf
[postgres]: http://www.postgresql.org/
