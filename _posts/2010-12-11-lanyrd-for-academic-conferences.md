---
layout: post
category: blog
title: Using Lanyrd for Academic Conferences
---

{{ page.title }}
================

This quarter I [found out][c] about [Lanyrd][l] (a word-play for [lanyard][w1]). It is a 
social-media oriented site targeted at users who may want to socialize information about 
conferences. Most of the current postings are related to technology, like [OSCON][oscon], 
[PGCon][pgcon] [RailsConf][r], etc.. but I think it could also be very useful for
[Academic conferences][w2].

In some academic fields (particularly in the area of Database and Information Management, which is 
where my research interests lie in) conferences are big, in the sense that most of the work that 
gets published is on the Proceedings of these events. Most of the people I know organize their 
schedule based on the dates when [ICDE][icde1], [VLDB][vldb1], [SIGMOD/PODS][sigmod1], [CIDR][cidr1] 
(among others) take place. This contrasts with other areas where journals are the main scientific 
communication medium.

I think having something like Lanyrd is very cool and I'd love to see more DB-related (and 
scientific in general) events get posted to it. I've added entries for next year's [ICDE][icde2], 
[VLDB][vldb2] and [CIDR][cidr2]. I also have sent a request to the creators to suggest them to 
include more deadlines to a [call][call]. Currently they only have fields for initial (abstract 
request) and final (notification) deadlines but many conferences have dates for abstract, 
notification, full-paper, and camera-ready.

So if you publish your work through conferences, I encourage you to start using Lanyrd!

As a side note, before Lanyrd I was using this nice [conference listing][bzl] maintained by
[Bin Zhou][bz]. I created a [calendar][g] out of it and a Yahoo [pipe][p] that takes the 
calendar's feed and converts it into a [map][m]. Lanyard provides a [calendar][c] for each user 
(just append `http://lanyrd.com/people/<user>/<user>.ics` to your profile's URL). So no map yet but 
I guess it's something they may be considering to add in the future. In the meantime I'm getting a 
calendar from [another yahoo pipe][np] but now it uses Lanyrd as the calendar source:

<script src="http://l.yimg.com/a/i/us/pps/mapbadge_1.3.js">
    {"pipe_id":"a7a222aced3f9215eabfba78a7ed3524","_btype":"map"}
</script>

  
  
**Update 12/12/10:** Found [SIGMOD 2011][sigmod2] entry added by [@marcua][m]. Nice :)

[c]:       http://commandn.tv/221
[l]:       http://www.lanyrd.com
[r]:       http://lanyrd.com/2011/railsconf/
[pgcon]:   http://lanyrd.com/2011/pgcon/
[oscon]:   http://lanyrd.com/2011/oscon/
[w1]:      http://en.wikipedia.org/wiki/Lanyard
[w2]:      http://en.wikipedia.org/wiki/Academic_conferences
[icde1]:   http://www.icde2011.org/
[vldb1]:   http://www.vldb.org/2011/
[sigmod1]: http://www.sigmod2011.org/index.shtml
[cidr1]:   http://www.cidrdb.org/cidr2011/
[icde2]:   http://lanyrd.com/2011/icde/
[vldb2]:   http://lanyrd.com/2011/vldb/
[cidr2]:   http://lanyrd.com/2011/cidr/
[sigmod2]: http://lanyrd.com/2011/sigmod/
[call]:    http://lanyrd.com/2011/vldb/calls/qfg/
[bzl]:     http://www.cs.sfu.ca/~bzhou/personal/conference.html
[bz]:      http://www.cs.sfu.ca/~bzhou/personal/
[g]:       http://www.google.com/calendar/embed?src=8k35jki51bu1ekhkoijmou5ung%40group.calendar.google.com
[p]:       http://pipes.yahoo.com/pipes/pipe.info?_id=133c29703cd055e2e01beda7a3187ff9
[m]:       http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=http:%2F%2Fpipes.yahoo.com%2Fpipes%2Fpipe.run%3F_id%3Dcf40397acedbf1f43718290e1241795c%26_render%3Dkml&sll=37.0625,-95.677068&sspn=38.911557,86.572266&ie=UTF8&z=2
[mc]:      http://twitter.com/marcua
[np]:      http://pipes.yahoo.com/ivotron/lanyrd
[nc]:      http://pipes.yahoo.com/ivotron/lanyrd
