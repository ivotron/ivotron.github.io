---
layout: post
title: TXN - Log-scaling paper
category: labnotebook
tags:
  - txn
  - hpc
  - slides
---

% Hursey et al. “A Log-Scaling Fault Tolerant Agreement Algorithm for a Fault Tolerant MPI”
% Ivo Jimenez
% 2013-05-31

# `tl;dr`

  - **goal**: fault-tolerant group communication on MPI

  - fault-tolerant `==` identify faulty processes

  - don't abort, let the application know which processes are dead

\note{issue on terminology. As we discussed previously, this should be fault-detection}

# context

  - fault-tolerant proposal: Run-through Stabilization [@hursey_run-through_2011]

  - provides a new call:

    ```cpp
        MPI_Validate_all(MPI_Comm* comm);
    ```

\note{they don't show examples of how this would get used. I guess this would be used after each 
group communication.}

# 2PC

![][2pc]

# 2PC (states)

![][2pc-states]

\note{
  - state transition diagram is a simplification of larger

  - states denoted by circles and the edges

  - terminal states are depicted by concentric circles.

  - edges: reason for the state transition (message received) at top ; message sent at bottom

  - combinations of failures among the states of coordinator/participants (4 x 4 x 2)

  - only 5 are relevant for termination (eg. one participant aborts, what happens next?)

  - in one case ($P_i$ receives notification from all $P_j$ that they are in the READY state) in 
    case 3 the participant processes stay blocked, as they cannot terminate a transaction.
}

# protocols

  - protocols:
      - `commit`
      - `termination`
      - `recovery`

  - authors provide `commit` and `termination` protocols

  - `MPI_Abort` when recovery is needed (as RTS doesn't provide this).

# "vanilla" 2PC

![][2pc-linear]

# log-scaling 2PC

![][2pc-tree]

# results (failure-free)

![][2pc-results1]

# results (failures)

![][2pc-results2]

# discussion (1)

  - how does it compare to other variants? [@al-houmaily_atomic_2010]

  - can transaction coordination be piggy backed on top of these fault-tolerant approaches?

  - my take:

    > for our purposes, it doesn't matter, we care about I/O. Our baseline performance of MPI group 
    communication is whatever the implementation we're using is capable of. We take it from there.

\note{
  this is what I got out of reading this paper.

  in other words, whatever we propose can be implemented in a fault-tolerant MPI. That is, it would 
  be an optimization to our algorithm.

  Question: In general, does any form of piggybacking means that something is optimized?
}

# discussion (2)

  - as noted, other non-blocking alternatives exist: 3PC or quorums.

  - if we had a fault-tolerant MPI, would we need transactional storage?

  - conversely, if we had transactional storage, would we need fault-tolerant MPI?

\note{
  Question: Is fault-tolerance the main need for I/O in HPC. In other words, are all the working set 
  size small enough that they fit in memory? If that's the case, wouldn't true fault-tolerant MPI 
  solve all the problems? I.e. if something like spark but for HPC existed, wouldn't that be it? Is 
  there an actual need for storage in the traditional my-memory-isn't-big-enough sense
}

# more related work

R. L. Graham, J. Hursey, G. Vallée, T. Naughton, and S. Boehm, **“The Impact of a Fault Tolerant MPI 
on Scalable Systems Services and Applications,”** Oak Ridge National Laboratory (ORNL); Center for 
Computational Sciences, 2012.

A. Skjellum, P. V. Bangalore, and Y. S. Dandass, **“FA-MPI: Fault-Aware MPI Specification and 
Concept of Operations. A Transactional Message Passing Interface & An Alternative Proposal to the 
MPI-3 Forum,”** University of Alabama Birmingham, Technical Report UABCIS-TR-2012-011912, Feb. 2012. 

# References

[2pc]: _posts/images/2013-05-31-hursey-2pc.png
[2pc-states]: _posts/images/2013-05-31-hursey-2pc-states.png
[2pc-fail]: _posts/images/2013-05-31-hursey-2pc-states.png
[2pc-linear]: _posts/images/2013-05-31-hursey-2pc-linear.png
[2pc-tree]: _posts/images/2013-05-31-hursey-2pc-tree.png
[2pc-results1]: _posts/images/2013-05-31-hursey-2pc-failure-free.png
[2pc-results2]: _posts/images/2013-05-31-hursey-2pc-failures.png
