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

The internal links to documents assumes the commit SHA-1 is the latest 
for the associated document. If this is not the case, then the link to 
github should be provided. Alternatively, a new asset can be created 
that is a copy of the modified asset, and a new entry added to the 
table. For example, if `tag1` links asset `s1`, the association is 
valid as long as the contents of `s1` are still valid[^valid]. If 
modifications for `s1` transform the content into something that 
doesn't align with the entry for `tag1`, then the link to the 
corresponding git commit should be provided or alternatively a new 
`s2` should be created that contains the (significant) modifications 
to `s1` and a new entry `tag2` should be added.

[^valid]: by valid we mean that the contents correspond to what it was 
originally registered in the table entry. Minor edits, reformat of 
text, etc.. make the asset still valid. Other types of modifications 
should be considered mayor and a new entry should be created.

Lastly, when an entry is similar to other, the `<tag>` keyword is used 
to specify which tag is the entry equivalent to, followed by the 
distinct assets that the entry differs on.

-----------------------------------------------------------------------------------------------------------
   tag             internal                                      external
-----------------  --------------------------------------------  ------------------------------------------
 cephforhpc-exp1   mode=4 described [here][l1] ; [script][s1] ;  [ior1] ; [iod_ceph1] ; [ceph1] ;
                   [analysis][a1]                                built-in ceph snapshots as transactions

-----------------------------------------------------------------------------------------------------------

[l1]: {% post_url 2014-01-30-cephforhpc-the-day-the-cephforhpc-project-becamed-my-thesis-topic %}
[s1]: https://github.com/ivotron/ivotron.github.com/commit/d7b8f9590fe6fbb8046787de950516e4baae2cf8
[a1]: {% post_url 2014-02-04-cephforhpc-mode4-initial-experiments-analysis %}
[ior1]: https://github.com/ivotron/ior_private/commit/0b30ac5580cdf9896a1a80c660b81c5503789b1a
[iod_ceph1]: https://github.com/ivotron/iod_ceph/commit/cb72b1207f0a1d16da8f429782180aa202d036ed
[ceph1]: https://github.com/ceph/ceph/commit/946d60369589d6a269938edd65c0a6a7b1c3ef5c
