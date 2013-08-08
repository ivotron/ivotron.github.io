---
layout: post
title: Intel - Pseudo Code for Simple Use Case
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

More detailed execution

# Use case 1: simple querying

> "Find all locations where pressure exceed 17 for year 2010"

```sql
FOR     '/UCAR/2010/'
WHERE   dataset_name = 'pressure' AND
        pressure > 17
```

## Client

```cpp
// we assume the following:
//   - EFF stack has been initialized
//   - file_id refers to the container
//   - event_q refers to the event queue
//   - out_ds is the dataset where the output should be written
//     and has been created

int x;
hid_t q1;
hid_t q2;
hid_t q3;
hid_t q4;
hid_t task;
hid_t out_ds;
uint64_t tid_read;
uint64_t tid_write;
H5_request_t req;
H5_status_t status;

const char script[] = "";
const char script_args[] = "";

q1 = H5Qcreate(H5Q_TYPE_GROUP_NAME, H5Q_MATCH_EQUAL, "/UCAR/2010/");

x  = 17;
q2 = H5Qcreate(H5Q_TYPE_DATA_ELEMENT, H5Q_MATCH_EQUAL, H5T_NATIVE_INT, &x);

q3 = H5Qcreate(H5Q_TYPE_LINK_NAME, H5Q_MATCH_EQUAL, "Pressure");

// combine queries

q4 = H5Qcombine(q1, H5Q_COMBINE_AND, q2, H5Q_COMBINE_AND, q3);

// create the analysis task

tid_read = 0;
tid_write = 1;

task = H5AScreate(file_id, q4, script, script_args, tid_read, tid_write, out_ds);

// ship analysis (asynchronously)
H5ASexecute(task);

// wait
H5EQpop(event_q, &req)
H5AOwait(req, &status)

// finalize
H5QClose(q4);
H5QClose(q3);
H5QClose(q2);
H5QClose(q1);
H5ASClose(task);
```

At this point the execution of the task has finalized (from the point of view of the client). Here 
we have the following three alternatives:

### 1 - Result in dataset

This approach assumes that the results of the query are stored in the output dataset and thus, in 
order to access the result of the query, we read it as a regular dataset read operation:

```cpp
ret = H5Dread_ff(out_ds, int_id, dpaceId, dspaceId, dxpl_id, r_data, tid_write, event_q);
```

where `out_ds` is the dataset that the analysis wrote to. We assume this is what it will happen 
since it's the most straight-forward thing to do.

### 2 - `<H5View,ION>` map

Associates `H5View` objects with the ION they are located at. Then the user can iterate over the 
map, take each `H5View` object, ask the corresponding ION for the list of references contained in 
the view and dereference them in order to access to underlying dataset/dataspace object. From that 
point on, the operation is as above (i.e. as a regular dataset read operation)

### 3 - Iterator

This is a client side iterator object that wraps the process outlined previously, that is, it 
aggregates the `H5View` objects that are spread among the IONs. This would take care of 
dereferencing each object, fetching it from the ION and putting it into the client's context. Many 
questions arise from this approach, among the important ones is the order in which we pull from the 
IONs (round-robin? pulling all values from a single ION, sequentially? others?)

## Server

Analysis task execution:

```cpp
// we assume:
//  - MPI is initialized
//  - we can invoke any H5* call that a client can

hid_t view;
hid_t query;

if (rank == 0)
{
  // we're the master, so we extract each of the components of the analysis
  // task (the object that the client created with the `H5ASCreate` function)
}

// send the query to each ION
MPI_Bcast(&query, MPI_H5QUERY, 0, comm);

// execute the query on each rank synchronously (triggers local VOL calls)
view = H5Vcreate(file_id, query, tid_read);

// invoke the python wrapper
exec_python_script(script, script_args, view, out_ds);

if (rank == 0)
{
  // finalize
}
```

The python wrapper is in charge of:

  * loading the python runtime
  * translating from `H5View` results into NumPy datasets (dereferencing datasets/dataspaces)
  * loading the reference to output dataset
  * passing script arguments
  * executing script
  * handling python exceptions

# Modified files

  * `src/H5FFpublic.h`: two new entries for `H5AScreate` (analysis shipping create) and 
    `HASexecute`.
  * `src/H5VLiod_server.h`: new reference to `src/H5ASpublic.h`
  * `src/H5VLiod_server.c`: function `H5VL_iod_server_eff_init` initializes analysis shipping 
    extensions too by passing MPI communicator and `fapl_id` reference.

# New files

  * `src/H5ASpublic.h`: analysis shipping API, defining `H5AScreate` and `HASexecute` function 
    signatures.
  * `src/H5AS.c`: implementation of analysis execution. This contains the code MPI-based code (see 
    [Server]). This is like other EFF client application running on CNs, with the difference that 
    the app runs on IONs

# Initialization

In `src/H5VLiod.c`, analysis shipping functions are registered against mercury.

Then, in IOD's server-side code (`src/H5VLiod_server.c`) `H5VL_iod_server_eff_init` initialization 
function, along with IOD initialization, the analysis shipping extension (see [New files]) is 
initialized too by giving it the MPI comm, as well as the instance of the IOD VOL plugin (`fapl_id` 
reference).

