---
layout: post
title: Intel - Analysis Shipping Guide
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

This document describes the prototype implementation of the Analysis Shipping Extension.

The analysis extension to the server-side HDF5 IOD VOL plugin allows the user of

# Client code

User provides:

  * Name of objects to be accessed
  * Script to be executed at each ION

If the


~~~ {#usage .cpp .numberLines}
H5ASinit(IOD_COMM); // initializes an EFF client

H5AnalysisTask task = {

  .datasets = "/G1/D1, /G1/G2/G3/D2, ...",

  .maps = "/M1, /G1/G2/M2, ...",

  .script =
    "from time import time,ctime\n"
    "print 'Today is',ctime(time())\n",
};

// synchronous
ret = H5ASexecute(&task);

assert(ret == 0);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Within python's environment:

  * `iod_comm` references MPI comm (can be used with `mpi4py`)
  * `local_shards` contains local slices (a.k.a. shards) for a given dataset.

For example:

~~~ {.python .numberLines}
def process_slice(slice):
  # this function
  # takes a slice of the
  # multi-dimensional array
  # and executes code on it

f = h5py.File('eff_file.h5')

ds = f['/G1/D1']

for s in local_shards['/G1/D1']:
   # do something with shard
   res = process_slice(ds[s])

   # communicate result with other(s)
   iod_comm.send(res, dest=3, tag=15)

f.close()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Server-side

# Installing

In this section we describe how to install and run the tests.

## Compiling using CMake

Assuming EFF's hdf5 and dependencies are installed in `/usr/local/`

```bash
mkdir build
cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=/usr/local/ \
  -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_TESTING=1 \
  -DBUILD_SHARED_LIBS=1 \
  -DHDF5_BUILD_HL_LIB=1 \
  -DHDF5_DISABLE_COMPILER_WARNINGS=1 \
  -DHDF5_ENABLE_PARALLEL=1 \
  -DHDF5_ENABLE_EFF=1 \
  -DHDF5_BUILD_EXAMPLES=1 \
  -DHDF5_INSTALL_BIN_DIR=/usr/local/bin \
  -DHDF5_INSTALL_LIB_DIR=/usr/local/lib \
  -DHDF5_INSTALL_INCLUDE_DIR=/usr/local/include/ \
  -DHDF5_INSTALL_DATA_DIR=/usr/local/share/ \
  -DAXE_INCLUDE_DIR=/usr/local/include/ \
  -DAXE_LIBRARY=/usr/local/lib/libaxe.a \
  -DIOD_INCLUDE_DIR=/usr/local/include/ \
  -DIOD_LIBRARY=/usr/local/lib/libiod.a \
  -DMPIEXEC_PREFLAGS="--hosts=localhost" \
  ../
```

## h5py

Assuming EFF's hdf5 and dependencies are installed in `/usr/local/`

Steps:

 1. install python
 2. install numpy
 3. install h5py
 4. Link `examples/h5ff*` and `test/h5ff*` binaries against the hdf5 library contained in 
    `/usr/local` (not against the ones in `hdf5/build/bin`, otherwise h5py will load `/usr/local` 
    while binaries will load `hdf5/build/`).

### OSX

Assumes homebrew is already [installed](http://brew.sh/)

```bash
brew install python
pip install numpy
pip install h5py
```

Before running the `examples/tests`, we need to make sure that `PYTHONHOME` points to homebrew's 
python instead of Apple's:

```bash
export PYTHONHOME=/usr/local/Cellar/python/2.7.5/Frameworks/Python.framework/Versions/2.7/
```

### Ubuntu

```bash
sudo aptitude install python
sudo aptitude install pip
pip install numpy
pip install h5py
```

### How to extend/add more EFF features

http://www.h5py.org/docs/meta/contributing.html?highlight=hdf5%20function#part-3-how-to-modify-h5py

for instance, `examples/h5ff_client` could be a python script instead, assuming that all the 
functions/data-structures used in the example
