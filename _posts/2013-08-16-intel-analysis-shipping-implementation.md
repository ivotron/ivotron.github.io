---
layout: post
title: Intel - Analysis Shipping
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

  * **goal**: make progress iteratively

  * end-to-end (very) basic prototype

  * basic, skeletal implementation

  * keep refining by adding on each iteration:

      * new functionality
      * tests

# client

```cpp
tid_read    = 0;
tid_write   = 1;
q1          = "pressure = 17";
script      = "....";
script_args = "...";
out_ds      = H5Dcreate(...);

task = H5AScreate(file_id, q1, script, script_args,
                  tid_read, tid_write, out_ds);

// ship analysis (synchronously)
H5ASexecute(task);

// finalize
H5Qclose(q1);
H5ASclose(task);
```

# client

  * output dataset is always created
  * for "query-only" tasks, output dataset contains the result of the query
  * the above is inefficient, possible alternatives:
      * return `<H5View,ION>` map
      * return an iterator

<!--

**map**: Associates `H5View` objects with the ION they are located at. Then the user can iterate 
over the map, take each `H5View` object, ask the corresponding ION for the list of references 
contained in the view and dereference them in order to access to underlying dataset/dataspace 
object. From that point on, the operation is as above (i.e. as a regular dataset read operation)

**iterator**: This is a client side iterator object that wraps the process outlined previously, that 
is, it aggregates the `H5View` objects that are spread among the IONs. This would take care of 
dereferencing each object, fetching it from the ION and putting it into the client's context. Many 
questions arise from this approach, among the important ones is the order in which we pull from the 
IONs (round-robin? pulling all values from a single ION, sequentially? others?)

  -->

# server

```cpp
hid_t view;
hid_t query;

if (rank == 0)
{
  // we're the master, so we extract each of the components of the analysis
  // task (the object that the client created with the `H5ASCreate` function)
  query = get_query_from_task();
}

// send the query to each ION
MPI_Bcast(&query, MPI_H5QUERY, 0, COMM_IOD);

// execute the query on each rank (triggers local VOL calls)
view = H5Vcreate(file_id, query, tid_read);

// invoke the python wrapper
exec_python_script(script, script_args, view, out_ds);

if (rank == 0)
{
  // finalize: wait for workers, prepare result and notify of termination
}
```

# server

python wrapper is in charge of:

  * loading the python runtime
  * translating from `H5View` results into NumPy datasets (dereferencing datasets/dataspaces)
  * loading the reference to output dataset
  * passing script arguments
  * executing script
  * handling python exceptions

# status and next steps

done:

  * basic server-side implementation
  * `H5View` data structure
  * hard-coded `H5Vcreate`

next:

  * setup testing environment (ctest)
  * write tests for the above
  * implement `H5Vget_elem_regions`
  * each worker will be able to iterate on a view

# later

  * Implement `H5Vcreate` properly so that it invokes local VOL calls

or:

  * Implement `H5Qcreate`
  * Extend `H5Vcreate` so that it reads the content of a query

or:

  * Implement `H5Qcombine`

or:

  * Integrate the Python runtime.
  * Wrap `H5View` objects around as `NumPy` arrays

or:

  * Allow writing to a dataset from python (wrap `H5Dwrite_ff` calls as NumPy array assignment).

or:

  * Define `H5ASAnalysis_task` structure
  * Implement `H5AScreate` function
  * Create encoding/decoding function for `H5ASAnalysis_task`
  * Allow clients to ship an analysis task

# higher-level issues

analysis task:

 1. decompose input in blocks (a.k.a. chunks or slabs)
 2. assign blocks to nodes
 3. **apply algorithm on each block**
 4. combine/merge/reduce
 5. iterate or write output

user cares about 3 and wants to bother as less as possible about specifics of 1-2,4-5

# decomposition

  * allow user to specify "granularity" of decomposition (chunk size)

  * make it part of querying mechanism

  * example:

    ```python
       FOREACH   DATASET IN '/UCAR/200*/*'

       WHERE     dataset_name = 'pressure' AND
                 lat < 100 AND lat > 200
                 lon < 100 AND lon > 200

       HYPERSLAB time = 2 AND
                 lat = 36 AND
                 lon = 36 AND
                 elevation = 10
    ```

  * instead of `HYPERSLAB`, `CELL` or `SHARD` could also be allowed


# block assignment

allow user to specify how to assign blocks to IONs:

  * round-robin
  * contiguous
  * user-defined

# combine

allow user to specify:

  * neighborhood (topology of block assignment)
  * types of communication:
      * global reduction (corresponds to MapReduce)
      * point-to-point
      * all neighbors
      * subset of neighbors
      * wraparound neighbors
  * user-defined combine code (eg. python script)

