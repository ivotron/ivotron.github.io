---
layout: post
title: Analysis of first `mode=4` results (these use Ceph's builtin snapshots)
category: labnotebook
tags:
  - cephforhpc
  - cephforhpc-exp1
  - msst14
  - phdthesis
---

# Results

**On peak performance**

```r
> d = read.csv("~/projects/homepage/images/spreadsheets/2014-02-04-mode4-results.csv", sep = "\t", header = TRUE)
> writes <- d[seq(1,nrow(d),4),]
> reads <- d[seq(2,nrow(d),4),]
> writes_with_snapshots <- d[seq(3,nrow(d),4),]

> writes[(writes$blksiz / writes$xsize) == 100 & writes$xsize == 4096,c("X.Tasks", "Mean.MiB.")]
   X.Tasks Mean.MiB.
9        1      1.58
21       2      3.10
33       4      5.49
45       8      8.74
57      16     13.01
69      32     18.42

> writes[(writes$blksiz / writes$xsize) == 100 & writes$xsize == 524288,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
81        1     38.85
93        2     74.70
105       4    102.21
117       8    152.75
129      16    176.76
141      32    208.62

> writes[(writes$blksiz / writes$xsize) == 100 & writes$xsize == 1048576,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
153       1     42.34
165       2     79.41
177       4    131.34
189       8    185.05
201      16    163.96
213      32    219.19

> writes_with_snapshots[(writes_with_snapshots$blksiz / writes_with_snapshots$xsize) == 100 & writes_with_sna pshots$xsize == 4096,c("X.Tasks", "Mean.MiB.")]
   X.Tasks Mean.MiB.
11       1      0.33
23       2      0.63
35       4      1.28
47       8      2.35
59      16      4.90
71      32      9.81

> writes_with_snapshots[(writes_with_snapshots$blksiz / writes_with_snapshots$xsize) == 100 & writes_with_sna pshots$xsize == 524288,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
83        1     22.47
95        2     40.05
107       4     81.08
119       8    114.87
131      16    164.64
143      32    210.42

> writes_with_snapshots[(writes_with_snapshots$blksiz / writes_with_snapshots$xsize) == 100 & writes_with_snapshots$xsize == 1048576,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
155       1     29.48
167       2     56.21
179       4     91.35
191       8    135.29
203      16    201.76
215      32    187.31

> reads[(reads$blksiz / reads$xsize) == 100 & reads$xsize == 4096,c("X.Tasks", "Mean.MiB.")]
   X.Tasks Mean.MiB.
10       1      4.26
22       2      7.93
34       4     14.87
46       8     25.75
58      16     40.27
70      32     52.41

> reads[(reads$blksiz / reads$xsize) == 100 & reads$xsize == 524288,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
82        1     64.18
94        2    123.86
106       4    203.95
118       8    234.18
130      16    316.15
142      32    355.72

> reads[(reads$blksiz / reads$xsize) == 100 & reads$xsize == 1048576,c("X.Tasks", "Mean.MiB.")]
    X.Tasks Mean.MiB.
154       1     68.44
166       2    127.51
178       4    208.77
190       8    248.46
202      16    313.78
214      32    233.70
```

  * From the above, only 1,2,4 clients is somewhat meaningful since 
    that corresponds to the number of physical nodes. 8 runs 2 
    processes per node, 16 runs 4, and 32 runs 8. This is reflected in 
    the shape of the graphs.

  * We don't see much impact of the snapshots. We need to figure out 
    how do they work but presumably they might take advantage of the 
    journaling done at the OSD level.

# Insights from first run

 1. how is the block size used in IOR?

    **a**: from [@shan_characterizing_2008], `blocksize` represents 
    the amount of data that each process writes on every transaction. 
    `xfersize` is the chunks in which the total `blocksize` is divided 
    in, i.e. for every iteration of a test the `xfer()` backend call 
    is invoked  `blocksize / transfersize` times. Thus, `blocksize` 
    must be divisible by `xfersize`.

 2. does the block size makes a difference in our results?

    **a**: It shouldn't.

 3. what `blocksize` should we choose?

    **a**: I think 64mb is OK initially. This is equivalent to the 
    FLASH3-IO benchmark

 4. is the checkpoint creation being measured as part of the results?

    **a**: IOR takes time measurements for:

     1. create
     2. open
     3. write/read
     4. close

    the bandwidth (MB/s) presented in the summary is the sum of all of 
    the above. We measure transaction initiation by timing the 
    `cp_begin()` invocation as part #1 and finalization by timing the 
    `cp_end()` call as part of #4.

 5. how do environment checks look like (see [these][p])?

    **a**:

      * iperf shows 1gb / sec
      * netcat shows 100 MB
      * the above is consistent with [Noah's tests][n]

 6. do I need to install ganglia to monitor network, memory, cpu, etc?

    **a**:

      * not in my opinion since block sizes are manageable, maybe 
        later

 7. do we need to monitor Ceph activity?

    **a**: same as 6

 8. how can we know which OSDs is each client writing to? ideally, we 
    want each to balance load uniformly? should we care or should we 
    trust CRUSH for small number of objects (one per client)?

    **a**: open question, might need to check with Noah.


# Comparison against FF DAOS Q5 benchmark

The document:

"Benchmark Report – DAOS FOR EXTREME-SCALE COMPUTING RESEARCH AND DEVELOPMENT (FAST FORWARD) STORAGE AND I/O - Milestone 5.4"

on IOR, reports throughput of 3500 MiB/s at 16 clients (1MB transfer 
size). The lola backend has the following characteristics:

 * 20 clients
 * 1 MDS
   * 1MDT based on 1 500GB disk
   * 32 GB of memory
 * 5 OSSs
   * 1 OST on each OSS based on 1 raidz2 VDev of 10 500 GB disks (5 
     OSTs in total)
   * 32 GB of memory
 * InfiniBand network

So from the above, we can see that 1 OST has 10 disks, having 50 disks 
in total. In our case, we have 10 OSDs with a disk each. We could 
divide their numbers in 5 in order to have a somewhat meaningful 
comparison. Thus, we should be getting 700 MiB/s although our 
theoretical throughput (based on [Noah's results][n]) would be 1G/s 
since that's the bandwidth of the 1GigE

# Snapshots

We don't see much impact, for large `xsize`.

[p]: http://www.sebastien-han.fr/blog/2012/08/26/ceph-benchmarks/
[n]: http://noahdesu.github.io/2014/01/31/ceph-perf-wtf.html
