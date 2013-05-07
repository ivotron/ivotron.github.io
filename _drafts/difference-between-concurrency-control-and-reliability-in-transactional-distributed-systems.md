# On the confusion of Concurrency, Reliability and Replication topics

"2PC and distributed commit protocols allow concurrent access to a distributed database".

The above statement is correct, but it has many different aspects intermingled in it. For someone 
that begins into the world of transactional systems, it seems that all of the following talks about 
the same issue:

  - transaction
  - concurrency control
  - atomic commit

In a distributed context, when we talk about concurrency control mechanisms (S2PL, MVCC, etc.) we 
can do so by assuming that "the distributed system is fully reliable and does not experience any 
failures (of hardware or software), and the database is not replicated. Even though these are 
unrealistic assumptions, they permit us to delineate the issues related to the management of 
concurrency from those related to the operation of a reliable distributed system and those related 
to maintaining replicas." [^1]

the above is a very nice way to cleanly separating these three intertwined issues:

 1. concurrency
 2. reliability
 3. replication

Concurrency control deals with concurrent access at the page- (or segment-) level. It can be seen 
from a distributed point of view, but in that case we don't have to deal with failures (logical or 
physical). At these level, the techniques that are available to us are:

<!-- taxonomy by Ozsu -->

Reliability refers to 2PC, 3PC, HATs, etc.

Replication refers atomic broadcast, paxos, etc..

[^1]: taken from [@ozsu_principles_2007], chapter 12

# References
