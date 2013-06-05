# Measuring Residual Capacity in SDN

This is what I have in mind for the basic admission control module using Floodlight. At some 
(configurable) time interval $t$:

 1. get available links by querying the link discovery module of Floodlight
 2. query the byte counters for each corresponding port of each link (also by querying floodlight)
 3. determine the amount of traffic $b$ for the interval
 4. determine the residual capacity $rc$ of a link by getting $tc - b / t$ (where $tc$ denotes the 
    theoretical capacity of the link (which in turn corresponds to the lowest capacity of the two 
    link's ports))
 5. make this our current snapshot of the network (update our stats db)

Whenever a new request comes in, we check our stats db to get the current state, build the route 
that the application would take and allow/deny the access.

LANL

they want to extend

 - fs-test, IOR

function shipping vs analysis shipping

  - both: serialize and send
  - function: IOD knows what it means (the logic of the function is implemented by IOD)
  - analysis: user knows about it (the logic of the function is implemented by user)
