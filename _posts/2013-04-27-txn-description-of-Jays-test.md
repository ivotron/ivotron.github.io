---
layout: post
title: TXN - HPC workloads and D2T tests
category: labnotebook
tags:
  - txn
  - hpc
  - d2t
  - transactional-storage
---

# {{ page.title }}

The main goal of the test is to replicate the workloads in HPC. The following is a high-level 
description of the D2T tests:

**write**

This one creates a transaction:

 1. Master registers to the metadata service a list of variables:
      - every var has a boundary (a bounding box?)
      - every var is updated by a single process.
 2. Every process operates locally on a variable by:
      - registers a chunk for the variable/txnid at the datastore
      - fills the chunk
      - inserts the chunk's metadata (updated boundary, associated transaction id, etc) in the 
        metadata catalog
 3. At the end, every variable gets activated (can be seen by others).

**update**

This is a loop that does the following:

 1. get the metadata catalog
 2. select oldest version of one var
 3. mark as in process in MD
 4. retrieve list of chunks for this var
 5. process
 6. write out new chunks
 7. make new MD entries
 8. delete old var version

After x versions, the process ends.

# HPC Workloads

The following is from Jay Lofstead:

> I don't know of any formal description of workloads for HPC simulations.  Most HPC IO papers hint 
at it, but few spend any time really talking about it. Here are some descriptions that have driven 
my work and thinking:
>
> **GTC fusion simulation** (http://phoenix.ps.uci.edu/GTC/ has a public, older version):
The data sizes are on the order of 64-200 MB/process for production runs. These are stored primarily 
in 2-3 large 2-D arrays that represent the torodial position of each particle with their temperature 
and velocities.
>
> Checkpoint/restart outputs are done generally every 15 minutes and dump that data volume. These 
are also used for later data analysis and all must be maintained.
Analysis only outputs are slightly smaller (something like 10%) and are output about twice as often. 
Again, these must be fully maintained.
There are also diagnostic output that happens on occasion. It is a few KB from a single process.
>
> **Chimera supernova code (2-D version)**:
> This code has about 100 variables, all of which are tiny. The aggregate data size for each of 
these is <= 1 GB making it easy to store them in a single process. The 3-D version I have no 
experience with. The 2-D version has output at an irregular interval defined by the maturity of the 
simulation run. They have a list of iteration counts at which to output data. The aggregate data per 
process is probably < 10 MB each
>
> **Chombo AMR-framework/Cactus/CTH and other AMR codes**:
> These have UGLY data problems. 2-D or 3-D don't really differ other than the data volumes. The 
simulation starts with a single grid decomposed across the processes. As the simulation progresses, 
when 'interesting' things happen, cells within the grid are refined into a grid of their own to 
reveal more data. This usually entails a finer grain time scale as well (10 iterations of 
calculations for the refinement compared to each for the higher level). This refinement process is 
spotty across the simulation domain meaning that only particular processes will have refinements 
while others do not. The refinement recursion can go several levels deep. I have heard of 5 or 6 
levels deep, but not had to deal with it directly.
There are a couple of ugly bits beyond the calculation and data distribution imbalance. For some 
simulations, the physics changes at a lower refinement level meaning that the data stored is 
potentially different.
>
>To output this data, you have to output each level. For the refinement levels, you have patches all 
over that each have to be written out separately. Chombo had a setup where they linearized all of 
the data to get IO performance, but it isn't a good solution. They had to store a series of maps to 
get into the data. That had to be incorporated into the analysis tools too.
To summarize, the data is a series of arrays each representing potentially a different portion of a 
refinement level. There are data values stored at each level that are either stored as a C-style 
struct for each array element or they decompose it so that there is an array for each element at 
each level (I think the latter is more common, except for Chmobo that just linearizes the struct 
with the array).
>
>**S3D combustion code and Pixie3D Magneto Hydro-Dynamic (MHD) code**: These both share a similar 
data setup. S3D has as many as 50 or 60 different variables that are tracked per run. They have 3 
possible data models used (small, medium, and large). They almost always run with small in 
production runs from what I understand (this is described in the six-degrees paper from HPDC 2011 in 
more detail). S3D output every 10 minutes, I think. Pixie3D outputs every few seconds using the 
small model and probably 10-15 variables. The data sizes for S3D are around 2 MB per process. 
Pixie3D I expect is something similar or up to 10 MB/process. The frequency of Pixie3D output is 
part of the challenge. They generally have a code coupling setup with a companion program that 
accepts the data and processes before sending to disk.
>
>Some other benchmarks to look at are **Flash**, another astrophysics code, and **MADbench** (out of 
core matrix-multiply). MADbench in particular is very different since it is both read and write 
intensive at the same time. I only know of these rather than having any direct experience.
>
> <https://www.mcs.anl.gov/research/projects/pio-benchmark> These are common benchmarks. I have 
historically had access to full applications and have not needed to use these. In the future, I will 
probably rely on these more.
>
> -------
>
> Generally, I have seen that science simulations have up to 20 MB/process data. Most are < 10 
MB/process for some reason I don't quite understand. I would think more data locality is better, but 
the shift to better performance through parallelization is apparently at a lower data level than I 
would expect. They have some collection of variables representing some value across a simulation 
mesh of some sort. Using 10 vars is reasonable for many simulations. Using many more is still quite 
valid, but the data per process must be scaled down to recognize the additional data per process. 
Chimera is a good example of this. Output every 10-15 minutes for a checkpoint/restart is pretty 
typical with maybe 10 seconds for a calculation iteration at most. I have seen them range from < 1 
second to 6-7 seconds. The frequency of the checkpoint/restart output is driven from the time it 
takes to output the data volume as much as anything. When the time drops to something more like 5% 
of wall clock time, it will happen more frequently, particularly when the data can also be used for 
analysis. We have observed this happening with GTC as we were developing ADIOS. Some sims have such 
poor IO performance that they don't do anything for resilience. Instead, they just hope that they 
get done before a failure occurs. If a fault happens, they start over.
>
> There are another class of codes that I am just started to get exposure to. These are engineering 
codes that do things like look at materials deformations under pressure/temperature or other kinds 
of things like that. These are used to see how some machine component will operate under certain 
conditions to judge failure potential or other kinds of information. Sandia uses a LOT of these in 
the weapons program. The thing that is different about these is that their simulation mesh is 
generally not a regular grid. Instead, they are either on an irregular mesh or even an unstructured 
mesh. These other setups have lots of simulation points at places where they expect interesting 
behavior to occur. For example, in a machine, joints and stress points will have many more data 
points. For these, you have to output a mesh in addition to the data. The data also has to have more 
placement information. The ugliest part of this is that when you want to read it for analysis, you 
cannot just calculate where some portion of the data is based on a regular mesh. Instead, you have 
to do much more complicated calculations and/or scanning of the data to find what you are looking 
for. Trying to address the IO needs of these kinds of codes is something I need to address.
>
> I hope this is helpful for a general HPC data overview. The other thing to know is that HDF-5, 
PnetCDF, and NetCDF all reorganize the data into a contiguous, single chunk (by default) before 
writing to storage. ADIOS just dumps each process independently and does the fix up on reading. The 
time spent to do the data reorganization is not scalable as I describe in the six-degrees paper. The 
overhead for reading is actually lower for many reading patterns for ADIOS in spite of the belief 
otherwise by the IO community. The ADIOS approach, as is, isn't scalable either, but it will get us 
further than the other, older approaches. A few people are thinking about what to do next, but not 
many. I don't see PLFS as much more than a patch on HDF-5. It can help a lot, but it only makes 
HDF-5 performance better. ADIOS can still beat it in almost all cases at the cost of a new API and 
file format, I believe. PLFS is worthwhile because it helps provide a transition mechanism towards a 
real exascale solution while we figure out what that is. The lack of direct comparisons between PLFS 
and ADIOS I find revealing in that way. If it were better than ADIOS, I'd expect it would get that 
comparison as well. I know some testing has been done, but the lack of reporting of the results of 
those tests just reinforces my belief.
>
> The whole downstream consumption of data, I have little direct experience with. I just know I want 
to avoid data crossing the disk controller as much as possible for better performance.

