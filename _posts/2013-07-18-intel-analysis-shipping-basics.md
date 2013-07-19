% Analysis Shipping Basics
% Ivo Jimenez

# Basic behavior

The following describes the basic behavior of the analysis shipping feature:

 1. The analysis service is an extension to HDF5 that gets linked to the VOL executable. Let's say 
    it's exposed through a hypothetical `H5AEpublic.h` API (see next subsection for alternatives).

 2. The analysis execution library gets initialized with an MPI communicator, in the same way that 
    IOD does. This is used to communicate among IONs when executing an analysis task.

 3. An analysis task (eg. `H5Query`) is sent from the application. Might be exposed through a 
    hypothetical `H5AE_execute_ff()` or `H5AE_ship_ff()` function that receives as parameter the 
    task to be launched on IONs.

 4. Mercury receives the call and it gets registered in an AXE queue, just as any other IOD-VOL 
    call.

 5. the piece of code that the analysis execution is running is basically a master/worker MPI 
    program that executes VOL calls in parallel[^vol]. Let's assume that this code is part of 
    `H5AE_execute_ff`'s implementation, in a hypothetical `H5AEimpl.c`.

 6. each worker will invoke VOL calls locally, wait for termination and send back a `DONE` message 
    back to the master ION, possibly sending the result of its sub-task too (eg. the list of values 
    that satisfied the query).

 7. the master is in charge of creating an H5View object and "returning"[^noasynch]

**Questions**:

  - how is the master receiving the result of workers' subtasks?

[^vol]: assuming that the call can be handled in the same way that any other `H5*_ff` call, the 
difference will be that the VOL calls aren't invoked directly, rather, the analysis executor will 
first coordinate the task in order to have all the ranks in the MPI communicator make (in parallel) 
VOL calls.

[^noasynch]: I'm ignoring asynchrony for now, mainly because I don't understand well how the event 
queues work

## H5AEpublic.h

This API would contain functions that allow an application to send/receive analysis tasks to remote 
active-storage nodes (in this case IONs). This can be generalized as much as we want, up to having a 
workflow execution engine abstraction, similar to the way we've discussed before. Initially, this 
would support shipping of `H5Query` objects.

**Questions**:

  - does this analysis shipping API have to be separate from the VOL API?
  - does it have to be generalized in some other way?
  - in current proposal, there's a dependency with some form of network communication (MPI in this 
    case), since IONs need to be coordinated. This might need to be abstracted in order to have a 
    generic Analysis Shipping API.

# Materializing results

IOD imposes the restriction that no more than one application can be writing concurrently to a 
container (due to synchronization between IOD and DAOS containers) [@bent_milestone_2013-1]. In this 
case an "app" is defined as whichever process that holds a handle to the mercury server (i.e. any 
application being able to ship functions to the same VOL process running on ION).

Since our proposal above is part of the VOL plugin, we aren't affected by this restriction. The 
"only" thing we have to keep in mind is to handle transaction IDs correctly. For this we have two 
alternatives:

 1. let the app handle transaction assignment (as part of the `H5AE_ship_ff` call)
 2. have the analysis execution figure out how to not mess the transactions associated to new data 
    (based on what the simulation app is writing).

Since the first alternative is the more straight-forward, we propose going with it and leaving the 
second as future work.

# External requests

We have to keep in mind the scenario where the analysis task isn't coming from CNs but from a 
scientist's workstation. In this case, since the process that runs locally is not part of the EFF 
stack, we have to device a way in which the user can communicate with the currently running EFF 
stack instance.

One way of doing this is to expose a "Discovery Service" as part of the server-side VOL process (a 
pre-convened Mercury function?) that allows the user to "query" a set of IONs to see what EFF 
instances are currently running.

This would be similar to the way the client triggers the initialization of EFF on the IONs, but 
backwards: the server initializes the client's mercury instance, registering the calls on the user's 
laptop. From that point on, the user is able to contact the desired EFF instance.

One caveat: having a user write results depends on the way in which results are materialized 
(previous section). Since the user doesn't know about the logic in which transactions get assigned 
from the app that runs on CNs, it won't be able to store new data (otherwise it could mess up the 
transaction ID assignment). We have two alternatives:

 1. Only let the user explore/query data.
 2. Implement solution 2 of the materialization problem (previous section) and let IONs coordinate 
    the associated transactions transparently.
 3. Initialize a new container (which implies initializing a new EFF stack instance) from the user's 
    side and write to it.

Option 1 is the most straight-forward, so we should go with it and let the others as future work.

# Handling python scripts

In order to handle python scripts, we can do it in two ways:

 1. Embed the python runtime in the analysis extensions (through the python [C bindings][pybinds])
 2. Extend `h5py` and execute remotely (i.e. python runs locally to the user/app and triggers 
    client-side VOL calls).

**NOTE:** this needs to be explored in more detail

# References

[pybinds]: http://docs.python.org/2/c-api/intro.html#embedding-python
