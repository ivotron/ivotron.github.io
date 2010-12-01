---
layout: post
title: Idea of General Purpose RDBMS Benchmarking Library
---

{{ page.title }}
================

As part of our [CMPS 278][c] project, me and my [teammate][r] are defined a benchmark that we would 
use to test some DBMSs under well defined constraints (I'll blog about this later). The point I want 
to make in this post is that one of the main difficulties that we've found for this project is that, 
AFAIK, there is no general purpose benchmark library. We found [some][b] but they're specific for a 
given workload, TPC in most of the cases.

As a consequence of this, our focus moved from defining the query set to worrying about trivial 
technical stuff, eg. we had to spent a huge amount of time modifying the code of the
[benchmark library][l] library that we ended up using. When you are benchmarking a DBMS, you care 
about the actual queries and their "shape", not about how to code Java threads properly.

So, based in our experience I decided to write a quick-and-dirty idea for a library that would be 
used for running benchmarks. In my opinion, a library like this would be composed of the following 
modules:

1. **Data generation**.
 
   It should abstract the data generation process. This would be just a wrapper for existing 
   workloads. We would just require the data to be produced in CSV format.

2. **Data loading**.

   This is easy since we have the DDL from previous phase. We'd read the CSV files and load them
   using JDBC. It may take a long time but it'd be really easy.

3. **Query generation**.

   Two ways of doing this:

   * If the benchmark already produces them (like [TPC-\*][t]), then we would just use those.
   * If not, then allow the user to define templates that would take as inputs:

     * Types of queries
       * simple counts (eg. `SELECT count(*) ... FROM .. WHERE` )
       * `SELECT *...` queries
       * aggregates
       * unions
     * Joins
       * how many?
       * Between which tables? PK-FK only?
       * equality joins only?
     * Selectivity factors? This would just ask the user for the actual actual figures as well as 
       the number of columns that a selection predicate can have. Having this, the library would 
       need to:

       * Scan the DDL to get the logical schema of the DB. Alternatively, obtain the schema 
         through JDBC's `DatabaseMetadata` class.
       * Obtain columns' cardinalities, either through `SELECT count(*) ...` queries or by 
         querying the system tables (possibly executing `UPDATE STATISTICS ...`)

4. **Workload generation**.

   This module would be in charge of grouping the queries generated in step 3. It could take from 
   the user a direct definition of these groups or the user would select 'categories' based on the 
   distinct factors defined in step 3.

5. **Query execution**.

   Concurrency levels. Metrics (throughput, response time, etc)

6. **Report generation**.

   Graphs, etc.


Assumptions about this hypothetic library:
 * No loading times (JDBC overhead) measurement
 * Domain knowledge agnostic at the application level (no population of domain POJOs on the Java 
   side), we just care about measuring the stuff defined in step 5


I'm planning to add more info to this proposal later, when I find more time to do so.

[c]: http://www.soe.ucsc.edu/classes/cmps278/Fall10
[r]: http://users.soe.ucsc.edu/~rekhap
[b]: http://wiki.oracle.com/page/Database+Benchmarking
[l]: http://benchmarksql.sourceforge.net
[t]: http://www.tpc.org
