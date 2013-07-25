---
layout: post
title: Found A Way of Approaching Exascale Transactional Storage
category: labnotebook
tags:
  - txn
  - ff
  - transactional-storage
  - log-structured-filesystem
  - hpc
---

# {{ page.title }}

In my quest of finding the right way to approach the issue of transactional storage in HPC, and 
after [discussions][disc] with the team, this is my latest.

# On the principles

IMO the issue boils down to:

  1. "light-weight" transactions
  2. function shipping

these two are fundamental in the FF stack. A good way of questioning is by examining the 
alternatives.

For 1, I'm trying to find a way of approaching this. I realized that the underlying FS at the IONs 
is PLFS, which is a log-structured file system. So an alternative is to look at this issue from this 
angle. I was trying to look at this as a pure concurrency control 
protocols/techniques/algorithms/etc issue, but that just doesn't work. There is a lot of work that 
deals with transactions layered on top of recovery-based mechanisms (such as WAL-based ones, eg. 
[@sears_stasis_2010]).

For 2, I'm almost blank in this one, but I think, based on what I've read so far, that transactional 
memory would be an approach that could embody it.

Questions so far:

  - Why not consider distributed transactional memory? How would it interact with MPI/OpenMP/etc.
  - Why that kind of light-weight transactions? If IONs are implementing atomic broadcast as a way 
    of communicating, we could piggyback on those messages and implement full transactions 
    [@kemme_using_2003].

# On the implementation

If the two issues mentioned above have to be taken for granted, then the following is what I see is 
the key issues on the implementation:

  1. Server collectives also used by IONs?
  2. IOD layer?

Questions:

  - Why atomic broadcast? We could have something chubby-like instead. Are there any hard facts 
    against this?
  - Why an IOD layer? Can we have CRUSH (or alikes) to be burst-buffer aware?

# Next steps

  - un-dust knowledge on WAL-based techniques:
      - read Ramakrishnan chapter on this [@ramakrishnan_database_1999].
  - read PLFS paper carefully and understand it thoroughly [@bent_plfs_2009]
  - read RVM paper [@satyanarayanan_lightweight_1994].
  - read Statis paper [@sears_stasis_2006]
  - search for latest ramified work from RVM. I'm not sure if Statis would be considered in this 
    same branch since it implements (AFAIK) full transactions, although it is presented as very 
    flexible library, and it might include already support for lightweight transactions.
  - main issue with Stasis: it's not distributed. Granola [@cowling_granola_2012] might be an 
    alternative to look at.

# References

[disc]: {% post_url 2013-04-23-ff-lug-talk-by-eric-barton %}
