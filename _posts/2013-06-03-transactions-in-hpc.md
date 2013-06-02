% Transactions in HPC
% 
% 

## tl;dr

  - transactional **capabilities** of exa-scale storage

  - transactional **requirements** of HPC applications

\note{

  - these two are fundamental for our project and aren't clear

  - at this point we know what we don't know, which is very useful IMO
}

# HPC transactional capabilities/requirements

## problem

  - one of the main motivations for having 2PC:

      - local transaction manager (LTM) may not be ready to terminate a transaction.

  - do we have the above scenario? We might, but we don't know... yet.

  - recently less-than-serializable alternatives have been proposed

  - how do we pick?

\note{
 - For example, if a transaction has read a value of a data item that is updated by another 
   transaction that has not yet committed, the associated scheduler may not want to commit the 
   former.

 - there has been uncountable objections to 2PC, yet Google and others uses it.

 - some weaker alternatives go from read-only transactions, to HATs, to eventual consistency (some 
   with OOM less overhead than 2PC)
}

## approaches

 1. systems perspective

 2. application requirements perspective

\note{
  - after spending most of the quarter reading (a lot)

  - I think we can frame the discussion in two axis
}

## systems perspective (1)

![][whole]

## systems perspective (2)

![][lrm]

## systems perspective (3)

- basic building block at every node: local **recovery** manager (LRM)

- main idea:
    - view exa-scale storage nodes as LRM
    - determine what type of concurrency features are enabled by such a LRM

\note{
  - start from the ground-up
  - examples:
      - a TM that uses conservative TO, guarantees a global timestamp ordering, which in turns 
        allows only serializable bernsteinconcurrency1987 schedules to run. The overhead of such an 
        approach is very high and usually systems allow different timestamps to interleave their 
        operations, which in turn allows transactions to be aborted (and thus provide weaker 
        isolation guarantees)
      - a segment-based LRM works better for multi-key transactions, whereas a page-based that uses 
        flush/no-steal can't guarantee that clients read their own writes searsstasis2010
}

## application requirements (1)

what isolation levels does my application need?

  - dirty reads
  - (non-) repeatable read
  - phantom reads

alternatives:

  - 2PC [@gray_notes_1978] and variants [@al-houmaily_atomic_2010]
  - independent (a.k.a. deterministic) transactions [@cowling_granola_2012 ; @thomson_calvin_2012]
  - HATs [@bailis_hat_2013-1 ; @bailis_non-blocking_2013]

\note{
 In terms of read-phenomena:

  A dirty read occurs when a transaction is allowed to read data from a row that has been modified 
  by another running transaction and not yet committed.

  A non-repeatable read occurs, when during the course of a transaction, a row is retrieved twice 
  and the values within the row differ between reads.

  A phantom read occurs when, in the course of a transaction, two identical queries are executed, 
  and the collection of rows returned by the second query is different from the first.
}

## application requirements (2)

determine what is my workload doing in terms of:

  - single vs. multi-object access
  - read/write ratio
  - degree of contention

multi-level isolation?

  - can we have a framework in which a system can operate under different "modes"?
  - provide APIs to let the application decide
  - architecturally similar to Stasis [@sears_stasis_2010]

\note{
  - what if we end up having all sorts of requirements?

  - let the app decide and create hooks to let the application determine what happens when conflicts 
    arise
}

# what should we do then?

## problem

  - hard to develop a "one-size-fits-all" transactional system

  - **main issue**: key design decisions influenced by:

      - workload
      - system context
      - storage

  - examples:

      - hyder: nvram
      - spanner: atomic clocks
      - sinfonia: workload as mini-transactions
      - calvin: cloud middleware
      - zookeeper: 100:1 ratio

## our assumption "space"

What can we assume at the core of our system?

 - per-record locking (eg. key-value stores)

 - ADIOS/PLFS

 - **object-based transactional API (IOD)**

 - any others I might be missing

\note{
  not sure what consistency guarantees ADIOS provides

  in terms of workloads, Jay has a paper entitled "six degrees", does this cover all the possible 
  access patterns of HPC. Can we create the analogous but for transactions in terms of contention, 
  read:write ration, etc.
}

## my proposal

Assume IOD:

 - more concrete: mock the FF IOD API using redis/leveldb/sqlite
 - we have this already, just a matter of "exposing" the API
 - the idea is to be API-compatible with IOD
 - we can then reimplement the IOD API on Ceph

In general, with an FF-like LRM, coordination boils down to **TID assignment**

\note{
  then, given the above we proceed in the two perspectives I mentioned earlier

  how does this boils down to TID assignment? because IOD guarantees execution in TID ordering. So, 
  from this point of view:

    - 2PC guarantees strict 'online' TID
    - deterministic transactions assign all TIDs 'up-front'
    - HAT assign it on an "as-needed" basis
}

## systems perspective

  - Analyze the systems/architectural consequences of having IOD:
     - embed IOD nodes (IONs) in the transactional system diagram
     - mark the pieces that IOD doesn't have
     - alternatively, the capabilities that IOD can provide (eg. we might be compatible with Hyder) 
       "as is".
     - analyze what we want to implement for the missing/existing parts

  - In general, we want to analyze the kind of transactional capabilities/trade-offs that we have 
    given IONs

## applications requirements

  - pick 2-3 workloads from [PIO][pio1] [benchmarks][pio2]
  - plus 1-2 from [OLTPBench][oltpbench] (TPC-C and YCSB)
  - implement them on our framework
  - we want to have comparable measurements in terms of TPS
  - implement:
      - granola
      - HAT
  - compare

\note{

six degrees paper has the description of workload


 - can we implement deterministic transactions in MPI?
      - can we anticipate the number of transactions?
      - can we anticipate the order of the transactions?
      - if we can, we assign TIDs at the beginning and then execute blindly

  - on workloads:
      - does fstest capture the IO patterns? Jay has a paper entitled "six degrees", does this cover 
all the possible access patterns of HPC. Can we create the analogous but for transactions in terms 
of contention, read:write ration, etc.

  - they are all implementable with timestamp-ordering
}

## later

  - based on the above, evaluate:

      - the effectiveness of having multi-purpose storage capabilities (can we have all possible 
        scenarios under different operation "modes"?)

      - take into account replication

      - what about recovery? given that we have transactions now, can we replace the current global 
        checkpoints with db-like recovery mechanisms (i.e. replaying/undoing based on the log)?

# your proposal

## References

[pio1]: http://www.mcs.anl.gov/research/projects/pio-benchmark/
[pio2]: http://www.cs.dartmouth.edu/pario/examples.html
[oltpbench]: http://oltpbenchmark.com/
[lrm]: _posts/images/2013-06-03-transactions-lrm.png
[whole]: _posts/images/2013-06-03-transactions-whole.png
