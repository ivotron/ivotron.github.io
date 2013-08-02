---
layout: post
title: Intel - Meeting Notes
category: labnotebook
tags:
  - intel
  - hdf5
  - ff
---

# {{ page.title }}

**atendees**: Eric Barton, John Bent, Gary Grider, Aaron Torres, Carlos, Quincey, Ruth, Jerome, Ira

It looks like we didn't get much input on specific use cases, since the discussion was around 
high-level features. Given this, and based on Gary's comment about what is a good-enough first 
implementation, I suggest we go ahead and keep refining the details for the use case I outlined, 
taking in consideration Eric's feedback.

In tandem with this, we could try to get more in use cases through other means. My advisor suggested 
talking to Tom Peterka (author of [@peterka_scalable_2011 ; @peterka_diy_2013]) since he has been 
working for several years on datamanagement for the scientific community. I don't know if it would 
be politically correct though. I guess we need to ask Gary first. I can go ahead and ask him if you 
want.

# discussion

from Aaron:

  - there are certain types of operations that don't need to trigger the whole communication 
    overhead in order to execute. Since the information we have is structured, we have the capacity 
    of knowing where things are located. For example, querying metadata means that the KV-store is 
    probed for a specific value, if we have 1000 IONs and the we're looking at is only at one ION, 
    we don't need to execute the same query on the 999 remaining nodes.

from Eric:

  - query has to be driven by the locality of the data (move data as little as possible): know, in 
    advance, what data is local (like MapReduce does)
  - emphasis has to be put on the "parallel enumeration" capability of query execution
  - if we think in terms of an iterator, the "pull" request will have to deliver results in a 
    parallel-optimized way
  - this can be shown by executing a global operation (eg. sum, count, median, etc) accross an 
    entire dataset
  - we have to add support for ordering, grouping of results. This determines the way in which 
    results are pulled by the iterator
  - we have to explore if current IOD API exposes a "tell me the hyperslabs (or keys) that are local 
    to this ION" type of operation. If it's not, then we might need to add more functions to API in 
    order to be able to optimize the execution.

from Gary:

  - in terms of demoing, the following would satisfy the feature:

      1. analysis shipping functionality
      2. "smart" execution (based on local information, per-ION nodes)
      3. communication among IONs
      4. ability to store results

    the above would be the basic building blocks on which more sophisticated things can run on (like 
    Eric's mapreduce scenario or Aaron's MDHIM example).

from me:

  - an optimization layer can be included that (conceptually) centralizes the knowledge needed in 
    order to do smart query optimization

# post-meeting discussion

Me:

One thing that I'm uncertain though, and that I think it's important to
know is what does Gary mean with "communication among IONs". Are we
satisfying his requirement through the way we use the master/worker MPI
coordinator? Or is he picturing the ability to communicate within the
analysis application?

There are certain types of analysis (the general patterns are described in
the slides I attached), where neighborhood communication is required, from
within the analysis app. For example, in our use case, the python script
would contain `if` statements that depend on messages being sent to other
nodes.

We can argue that the above is possible as long as you break your analysis
in sequences of h5query/script pairs, similarly to the way in which
mapreduce jobs are composed. Alternatively, we might be able to give
access to the MPI communicator within python.

So, we have two alternatives:

  1. Communicate implicitly through the storage system
  2. Provide access to the communicator within python

I have heard Gary said in the past that he's very against 1. So I think it
would be important to get his feedback on this, unless you guys are
certain that we are covering his requirement in the h5query/script
composability I referred above.

Ruth:

We may want to discuss this further among ourselves.

Communicating across the IONs is not equivalent to communicating through
the storage system in my mind.

If we write something to the file, then look that up to see it's value
and do an action based on that value, that's communicating through the
storage system.

If we say "what's the value for this key" and the key happens to be in
the BB on another ION so IOD has to fetch it from there, that's not (to
me) communicating through the storage system. And, it doesn't involve the
user doing any explicit communication either.

Me:

IMO the last point above introduces confusion: the fact that an IOD call
can trigger inter-node communication if the arguments to the IOD function
aren't aligned to the underlying sharding (local key range in the case of
KVs, layout in the case of arrays, strip in the case of blobs). I think it
would be helpful if we treat it as an orthogonal and, at least initially,
ignore alignment and just assume that everything is local, and leave the
alignment issue as future optimization work.

A way of defining "communication through the IO system" that I think works
for us: whenever the analysis app controls its flow based on what other
processes have computed. In general there are two types of communication
used in analysis apps: global reductions and neighborhood communication.

Ruth:

If we compute 'local values' on each ION then need to compute some
overall value from all the 'local values' - how does that get done?
it's a different question than the KV above.
- maybe not one we have to do this project
- the "reduce part" Eric was talking about I believeŠ

Me:

In our current proposal, the above can be done by setting up two analysis
rounds: one generates local averages and the second aggregates them. This
last assumes that all the averages were written to the same node. An
alternative is to have the aggregation execute on the client side. If we
want a more robust way of supporting global reductions as part of the
analysis execution, we need to have a better query optimization strategy
that would take care of executing single-node analysis tasks (or executing
queries only on the sites that are relevant for the query, as Aaron
mentioned).

Ruth:

While Gary's opinion is indeed valuable and does matter, we won't
necessarily do what he wants - need to think through things ourselves too.

With your use case example, I'm still not sure what the 'slabs' are and
how they get mapped to / executed on the various ions & data local to
those.   And, what would we do if we wanted a global average Š how would
that get communicated (not that it's necessary for this first step, but
not something I understand how to do).   The "do the query for matches &
operate on local pieces may require communication & is something needed)

(Sorry I can't talk exactly in the terms you use, but they aren't ones
I'm totally comfortable with at this pointŠ hope translation is possible
& not too hard).

Me:

All concepts/comments/questions will be clearer once we have a more
detailed end-to-end example. I'm doing this by adding more details to the
use case we're currently using, and doing small extensions to it for the
cases where different communication requirements are needed and how these
can be satisfied by communicating within the application or through the
execution-environment. I will send the extended use case later today.

