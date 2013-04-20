---
layout: post
title: FastForward IOD As We Understand It
category: labnotebook
tags:
  - fast-forward
  - iod
  - transactional-storage
  - hpc
---

# {{ page.title }}

From our meeting and after discussing among ourselves, this is what we understand about how IOD API 
and its expected behavior.

# Transactions

This is a high-level description of a transaction:

> A transaction is analogous to the generalization of POSIX consistency semantics: I can choose an 
arbitrary set of extents that should be updated atomically (for instance an atomic writev). In the 
case of FF, this is more general because there are also objects and extents and other resources. A 
transaction also creates a labeled version of a container.

Consider an empty container and a sequence of transactions:

    TX1: w(a) w(b)
               |
               |
    TX2: w(a)  |
               |
               v
    TX3:      w(b)

    TX4: w(a) w(b)

The independent transactions could be executed in any order by the system (i.e. the clients 
submitting the TXs race and its the responsibility of the app to determine who wins).

## Consistency

The order in which the independent transactions occur is determined by the application. For 
instance, the first two TXs are independent and the application doesn't care what order they are 
executed. However, the application may impose that the last TX occurs after the first two, since it 
overlaps. In short, every operation has to specify what transaction is reading/writing to/from. That 
is, there's no automatic decision being made by the system of which version of the data to return:

  - if a new transaction 3 wants to read `a` from transaction 2, it can do it as long as transaction 
    2 is in `READABLE` state.
  - if transaction 2 is NOT `READABLE` and `TX3` wants to read it, it will have to wait 
    asynchronously (register a callback).

All the cases are specified in the state diagram contained in the IOD design document 
[@bent_milestone_2013].

There's no MVCC-like (nor lock-based control). In this sense, every transaction creates a new view 
or "layer" of the data and the version of the data that every application views depends of what 
other transactions on top of it have commited and what data they've touched. For example, assuming 
that transaction 1 is `READABLE`:

  - if `TX3` reads `b`, it will read the value comming from `TX1`.
  - if `TX3` reads `a`, it will read the value comming from `TX2`.

The way in which evolving data is "layered in views" allows the IOD to abort/commit rapidly by 
either moving a transaction to FINAL state or to ABORT (with the option of aborting any transaction 
above it). This is due to the fact that the relationships are implicitly defined over a simple, 
flat, monotonically increasing numeric namespace.

Note there is an alternative way to view a transaction once labels/version are involved, in which a 
transaction depends on a parent version. This is common in MVCC style truncations. When I talked to 
Eric he mentioned that they didn't want to enforce any consistency model to the user, so their 
philosophy is to provide fast primitives that can be used at higher levels. Slide 7 of his LUG talk 
summarizes it nicely.

At this high-level stage, three important questions come to mind with respect to these lightweight 
transactional "primitives":

  - Are they appropriate for the use case they are targeting? What are the alternatives (that 
    achieve the same level of semantics)?
  - Are they generic enough? How many other use cases that require this "light" transactions could 
    be supported?
  - If needed, these primitives would certainly allow to create middleware on top that achieves 
    stronger transactional semantics. In this scenario, would these primitives be the correct ones? 
    Do we even care if they aren't?


## Versioning

An application chooses a numeric label for each TX. Above, transactions 1, 2, 3 and 4. The labels 
can be arbitrary, but the ordering among labels is important: they have to be monotonically 
increasing

Example 1
---------

TX_1 is committed. A consistent view of the container at label 1 is the original objects A and B.

Example 2
---------

TX_1 then TX_2 is committed. A view of container at label 1 is the same. At label 2 we get the 
original object B and the new object A.
