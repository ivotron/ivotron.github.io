---
layout: post
title: Analysis Shipping High-level
author:
  - name: Ivo Jimenez
category: labnotebook
tags:
  - h5
  - hdf5
  - ff
  - q6
---

User/application sends script by doing something like:

```python
  # map - script executed at each ION
  # combine - script used to combine results
  obj = H5ASexecute(map, combine)
```

Prior to the execution of the `map` script, there is an 
introspection phase at the master ION where the referenced objects 
(datasets) are obtained. This is done by reading scripts and 
finding the references to the objects (datasets).

> **ivo**: who is in charge of this? this can ceirtanly be done within 
python but it will involve a "dialogue" between the C-side and the 
python env.

For each referenced object, its layout is queried in order to find 
which IONs should the script be sent to.

> **ivo**: who is in charge of doing the querying of the layout? 
In my branch, this is done in C and is done prior to the loading 
of the python environment. This is done as part of the body of the 
`H5ASexecute` function. Would this still be the case? Or is this 
going to be part of the layout routines that Mohammad will 
implement?

`map` is the python script part that gets executed locally on the IONs 
and invokes the `H5Q*` routines and produce as output `H5V*` 
instances.

> **ivo**: what's the HDF5 calls that python environment can 
interface with? can the `map` write to a file/dataset?

`combine` gets executed at the master ION, which handles the 
data returned by each mapper. the data is sent from the 
workers to the master by dereferencing the view objects at 
each ION.

> **ivo**: how is the base data that views are pointing to 
going to be retrieved from the worker IONs to the master? In 
other words, is the output of the `map` a list of references 
to base data or the actual data? Are these sent immediately to 
the master or they are "left" in the workers and then pulled 
from the master?

> **ivo**: same as with the `map`, what's the interface that 
the combine part has available to it? is able to write to the 
container? can the combine part talk to worker IONs (within 
python, eg. through the IOD comm)?

I guess, the main factor that will determine how python-related things 
are implemented is if only H5Q and H5V routines will be available (vs. 
the whole hdf5_ff wrappers).
