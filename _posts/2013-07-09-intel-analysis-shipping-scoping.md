---
layout: post
title: Intel - Questions on Analysis Shipping
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

The following is the high-level use case we envision for the _Analysis Shipping_ feature:

 0. User has access to an IOD instance that a given application running on CNs is making use of, and 
    decides to explore the current state of the compute job.

 1. User writes a query (by creating an `H5Query` object) that specifies the criteria that data 
    residing in the corresponding HDF5 container should match, as well as the way in which the 
    results of the query should be organized.

 2. User sends query to an ION so that it gets executed.

 3. ION returns a result object (tentatively an `H5View` object), which is composed of metadata 
    about the query result and references to the objects that are temporarily stored in IOD (i.e. 
    the query result).

 4. User can explore the result by iterating through it.

 5. User can use the result as input to other analysis routines, which in turn can generate new 
    groups/datasets in the same HDF5 container.

The above is in general what we would like to provide the user with. At this point there are several 
unknowns that depend on the capabilities provided by IOD (and our correct understanding of them), 
the assumptions made on client infrastructure, capabilities of IOD to execute user-defined code, 
among others. We will frame our questions in terms of each of the steps presented previously.

## The analyst context

In terms of the infrastructure that the analyst has available, we have identified two alternatives:

  1. user wants to have IONs execute the analysis in its entirety
  2. user has access to a cluster which can be used to run analysis tasks.

In the first scenario, user assumes that IONs are capable of handling the analysis. In the second, 
the scale of the analysis is large enough that it requires a cluster (distinct from the one running 
the main scientific computation) of its own in order to perform well.

The analysis application might be:

  1. an MPI job
  2. a python script[^h5py]
  3. others

**Questions**:

  - does it matter what we assume about the context and analysis application?
  - if it does, which one should we target?

[^h5py]: [`h5py`][h5py-org] is a potential candidate to be extended to support the EFF HDF5 analysis 
extensions. The current version has support for parallel HDF5 (through the use of `mpi4py`).

## Query specification

User will specify a query by creating an `H5Query` object and making use of the `H5Q*` functions. 
See [@koziol_milestone_2013-6] for a preliminary example.

**Questions**:

  - how does a user specify ordering of results? eg. if it will iterate through the results, how 
    does she specify what to "see" first?
  - same as above but for grouping (eg. group results by timesteps).
  - declarative languages can be defined on top of the `H5Q*` facilities to ease the specification 
    of queries, especially for environments where the user doesn't interact with HDF5 abstractions 
    directly[^scipy]. Is this something we should be anticipating?

[^scipy]: `h5py` uses Python and [`SciPy`][numpy] abstractions (i.e. no `H5*` objects are exposed).

## Query execution

### Launching

IOD doesn't expose any way of launching an I/O operation on multiple IONs, i.e. user app needs to 
execute a parallel (MPI) job in order to trigger the parallel execution of an I/O task. In other 
words, IOD can't, on its own, automatically instruct the parallel access to PLFS shards for an 
specific array/blob object. This means that in order to execute a query on IOD, an ION will have to 
execute its own MPI job.

**Questions**:

  - will IOD (more specifically the server-side Function Shipping daemon) be capable of launching 
    MPI jobs for analysis shipping directly on the IONs?

### Parallel execution

We want to exploit as much as possible the parallel features of IOD. In order to do so we can:

  - execute according to the layout of the HDF5 container (i.e. executing concurrently on distinct 
    groups/datasets).
  - for each of the above, execute concurrently at the IOD-object-level (distinct shards of 
    KV-stores & array/blob objects).

Number 1 is straight-forward, as it's a matter of correctly referencing the paths of the objects on 
which we want to execute a query. For 2, as per [@bent_milestone_2013-1], IOD exposes mechanisms to 
control the sharding/layout of objects.

**Questions**:

  - Does the IOD API exposes enough information to trigger the parallel access to object shards?
  - What other aspects can we review in order to identify if more control is needed at the IOD API?
  - Would we eventually need to bypass the IOD API in order get the behavior that we want?
  - How would HDF5 indices be used? (Maybe we should expose IOD/DAOS sharding to index creation, to 
    speed it up too?)

### DAOS shards

**Questions**:

  - What happens to IOD shards when not running on burst buffer?
  - Will IOD present DAOS shards as its own?
  - If a particular TID (or version) is being pulled from DAOS into IOD, what's the layout it will 
    have? Would it be as if it had written by an app running on CNs (but flattened)?

## Query result

At this point is not clear if the `H5V*` facilities will be enough to handle query results. One of 
the main issues is whether the user will be able to create new datasets from a view. If the user is 
able to manipulate the result in order to create new data (see next section), then we need to 
provide easy ways of defining new files/groups/datasets that can store the newly generated data. An 
alternative is to create the metadata of an HDF5 file (the hierarchical structure) that contains 
only the result.

**Questions**:

  - representation: h5view vs h5file
  - is there a need to specify the logical/physical ordering of a query result

<!--
 SELECT and GROUP BY clauses in SQL
-->

## Manipulating Results

### User-defined Functions

The real power of an analysis shipping feature is the possibility of generating new data. By 
allowing the user to send analysis routines that get applied to the result of a query, new 
information gets generated. The main idea is to allow a user to answer questions such as:

> get the average temperature for cities whose altitude is above 17, sorted monthly over the 
2000-2010 period

In the above example, the query capabilities allow the user to geo-reference and group 
(geographically and over time) points in datasets, as well as filter out some values that are not of 
interest. It then instructs the system to apply an average to the values that resulted from its 
query. Ideally, the average function might be replaced with any user-defined function. More 
HPC-oriented examples are mentioned in the next section.

**Questions**:

  - is it something we should target for the summer project?

### DAG-based workflows

Analytical tasks can be generalized as directed acyclic graphs (DAG) that get executed on IONs. We 
can reframe the entire discussion of the Analysis Shipping feature around it. Doing so would allow 
us to be more generic since many use cases can be embodied in it: eg. from HPC[^hpc-wf] and other 
fields[^bigdata-wf].

[^hpc-wf]: A good overview of existing workflow management systems is contained in 
[@ludascher_scientific_2009]. Kepler, Pegasus, Taverna and Triana are compared.

[^bigdata-wf]: Examples such as [Business Intelligence][bi], [Big Data][mr-patterns] and
[Distributed Machine Learning][mlb] all fit into the DAG-based approach.

**Questions**:

  - all of the issues discussed previously in the context of query execution apply. The main 
    question is whether to think of the analysis feature in DAG-based terms?

## Target examples

Given the bast number of use cases that can be targeted, it would be useful to narrow down a couple 
of specific examples in order to focus better the project and its deliverables. Possible ideas 
include:

  - Simple queries such as:

      - find all objects named "foo"
      - find all the elements having values > 34, and so on.

  - We can also look for more complicated ones (taken from the SciHadoop paper 
    [@buck_scihadoop_2011]):

      - Apply the median function to a time-range, over sets of data contained in two adjacent days, 
        in a given area (defined by a lat x long box) within an elevation range.
      - Regrid the pressure variable along time and latitude dimensions using units weeks and full 
        degrees, respectively. Interpolate using average.

    We can extract the querying part for these examples.

  - Look for more examples in recent published articles [@su_supporting_2012 ; @leyshock_agrios_2012 
    ; @sehrish_mrap_2010 ; @wang_scimate_2012 ; @wang_supporting_2013]. Similarly as above, we can 
    extract the querying part from the examples.

  - Others involving more complex user-defined code:

      - [AMUSE examples](http://www.amusecode.org/doc/examples/)
      - [distributed machine learning][scikit] (such as [clustering algorithms][pydata])

# References

[mr-patterns]: http://highlyscalable.wordpress.com/2012/02/01/mapreduce-patterns/
[numpy]: http://www.scipy.org
[mlb]: http://www.mlbase.org
[h5py-org]: http://www.h5py.org/
[bi]: http://en.wikipedia.org/wiki/Business_intelligence#Business_intelligence_and_business_analytics
[scikit]: https://github.com/scikit-learn/scikit-learn/tree/master/examples
[pydata]: https://github.com/pydata/pyrallel
