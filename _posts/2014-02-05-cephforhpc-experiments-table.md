---
layout: post
title: Experiments table for PhD thesis
category: labnotebook
tags:
  - cephforhpc
  - phdthesis
  - experiments
  - reproducibility
  - provenance
---

The main reason for having this table is to ease provenance and
reproducibility.

This entry provides a table that associates experiment tags, with
internal and external assets (docs, figures, etc). The tags are actual
tags on the jekyll git repo. Ideally, a commit should include all the
internal dependencies, but sometimes this is not the case. Also,
external dependencies can't be tracked so we're doing it explicitly
here.

With respect to versioning of internal docs, we have "precedence" 
rules when trying to determine what's the latest version of the asset:

  1. the version corresponding to the commit associated with the 
     experiment tag. This should be the main form of 
     version-determinism for assets that are evolved between 
     experiments, i.e. assets that are shared among table entries.
  2. if the document isn't "shared" among entries, that is, changes 
     done to it don't invalidate an entry in the table, then any 
     subsequent version of the asset is still valid [^valid].
  3. Other "stronger" types of modifications to assets should be 
     considered mayor and either a new entry should be created, since 
     effectively it makes the original entry inconsistent with the 
     latest version of the asset and it becomes ambiguous what version 
     of the asset to look at.

[^valid]: by valid we mean that the contents correspond to what it was 
originally registered in the table entry. Minor edits, reformat of 
text, etc. are OK.

Lastly, when an entry is similar to other, the `<tag>` keyword is used 
to specify which tag is the entry equivalent to, followed by the 
distinct assets that the entry differs on.

-----------------------------------------------------------------------------------------------------------
   tag             internal                                      external
-----------------  --------------------------------------------  ------------------------------------------
 cephforhpc-exp1   mode=4 described [here][l1] ; [code][s1] ;    [ior1] ; [iod_ceph1] ; [ceph1] ;
                   [analysis][a1] ; [spreadsheet][ss1]           built-in ceph snapshots as transactions

 cephforhpc-exp2   `exp1` ; [analysis][a2] ;                     `exp2` ; [gdoc2]
                   two configurations for [script][c2]:
                   xfer=1m,blocksize=64m and
                   xfer=4k,blksize=256k ; spreadsheet
                   [1][ss2-1] and [2][ss2-2]

-----------------------------------------------------------------------------------------------------------

[l1]: {% post_url 2014-01-30-cephforhpc-the-day-the-cephforhpc-project-becamed-my-thesis-topic %}
[ss1]: {{ site.url }}/images/scripts/2014-02-04-mode4-results.csv
[c1]: {{ site.url }}/images/scripts/iod_ceph_experiments.sh
[a1]: {% post_url 2014-02-04-cephforhpc-mode4-initial-experiments-analysis %}
[ior1]: https://github.com/ivotron/ior_private/commit/0b30ac5580cdf9896a1a80c660b81c5503789b1a
[iod_ceph1]: https://github.com/ivotron/iod_ceph/commit/cb72b1207f0a1d16da8f429782180aa202d036ed
[ceph1]: https://github.com/ceph/ceph/commit/946d60369589d6a269938edd65c0a6a7b1c3ef5c
[a2]: {% post_url 2014-02-06-cephforhpc-mode4-second-round %}
[c2]: {{ site.url }}/images/scripts/2014-02-04-mode4-results.csv
[ss2-1]: {{ site.url }}/images/spreadsheets/2014-02-05-cephforhpc-exp2_1m.csv
[ss2-2]: {{ site.url }}/images/spreadsheets/2014-02-05-cephforhpc-exp2_4k.csv
[gdoc2]: https://docs.google.com/spreadsheet/ccc?key=0AnohAxx-m2sQdE1zZFZLNGJxMXB6R1UwQldzaEk5Mmc&usp=sharing
