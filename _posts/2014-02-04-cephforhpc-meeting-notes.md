---
layout: post
title: They day the 'Ceph For HPC' project became my thesis topic
category: labnotebook
tags:
  - cephforhpc
  - msst14
  - phdthesis
---

  * early results for mode #4 (see [here][n] for meaning of modes) 
    show that snapshots are heavyweight when done in Ceph. Need to 
    start thinking in other ways of implementing transactions. Might 
    end up doing something more structured like efficient time-travel 
    paper [@soroush_time_2013] but this would work but only for the 
    multidimensional array.

  * I went and looked at the FF DAOS documents. It is clear that they 
    are implementing a lot of stuff that already exists in Ceph. In 
    order for Ceph to be a competitor to DAOS/IOD we need:

      * flash tier management (extending CRUSH maps)
      * infiniband
      * IOD class object to handle:
          * IOD logic (sharding, ranks, etc)
          * flash-based, log-structured formats (replace zfs)
      * efficient OSD versioning for each tier
      * collective transactional atomicity

  * Jay mentioned MADBench2 as a use-case that wouldn't be supported 
    by IOD. I was looking at the MADBench2 homepage, [this other 
    page][p] and also went back to see how it's referenced in the IOR 
    paper [@shan_characterizing_2008](I tried to look at the source 
    code but couldn't find a working link to it). It looks like the 
    write/read pattern is done on a stepwise fashion, i.e. the entire 
    matrix is completely written into the file system and then is read 
    in, re-written back and read one last time. If the above is 
    correct, this would be supported in something like IOD. The 
    problem arises when two ranks want to write to the same 
    object/block/shard/ within the same transaction.
    **update**: he mentioned he didn't know, so the above is correct.

[p]: http://www.cse.psu.edu/~seokim/tutorial/MADbench2
[n]: {% post_url 2014-01-30-cephforhpc-the-day-the-cephforhpc-project-becamed-my-thesis-topic %}
