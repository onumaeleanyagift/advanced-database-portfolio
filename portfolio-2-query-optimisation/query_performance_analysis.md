# Query Performance Analysis

**Course:** MIT 8103 Advanced Database Systems  
**Portfolio:** 2, Query Processing and Optimisation  
**Case study:** TransMove Logistics (simulated)  
**Database:** PostgreSQL 18, accessed through pgAdmin 4

## 1. Purpose

This activity examines how PostgreSQL executes shipment lookups, status filters, and joins. It uses `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` to inspect execution plans, actual row counts, buffer activity, planning time, and execution time.

## 2. Baseline queries on the TransMove database

The production-style case-study database contains three shipment records, two customers, and three depots at the time of testing.

| Query | Observed plan | Planning time | Execution time | Observation |
|---|---|---:|---:|---|
| Search by `tracking_code` | Index Scan using `shipments_tracking_code_key` | 2.805 ms | 6.438 ms | PostgreSQL used the unique index to locate the matching shipment. |
| Filter by `shipment_status = 'In Transit'` | Sequential Scan | 0.694 ms | 0.083 ms | PostgreSQL checked the three shipment rows and returned one match. |
| Join shipments, customers, and depots; sort by `created_at` | Sort over Hash Join operations | 4.363 ms | 4.505 ms | PostgreSQL joined the three tables and sorted the three returned rows. |

The measurements above are from individual executions. They are useful as recorded evidence, but the dataset is too small to support broad performance claims. Execution times can also vary between runs.

## 3. Statistics refresh on the join query

The following statements refreshed the planner statistics for the three tables:

```sql
ANALYZE shipments;
ANALYZE customers;
ANALYZE depots;
```

Before `ANALYZE`, the execution plan estimated around 110 rows for some operations even though only three shipment rows were present. After `ANALYZE`, the shipment scan estimate was three rows, matching the actual row count. PostgreSQL also changed parts of the join plan, using a Nested Loop and Materialize operation in the revised plan.

| Measurement | Before `ANALYZE` | After `ANALYZE` |
|---|---:|---:|
| Estimated rows at the shipment scan | 110 | 3 |
| Actual shipment rows | 3 | 3 |
| Planning time | 4.363 ms | 12.853 ms |
| Execution time | 4.505 ms | 0.512 ms |

The lower execution time occurred in the run after refreshing statistics. This single comparison does not prove that `ANALYZE` alone caused the entire timing difference. The important observed change is that the row estimate became aligned with the small dataset and PostgreSQL selected a different plan.

## 4. Index benchmark using 100,000 simulated records

A temporary table named `shipment_status_benchmark` was generated for a controlled index experiment. It contains 100,000 fictional benchmark rows:

- 500 rows have the status `Pending`.
- 99,500 rows have the status `Delivered`.

The table is temporary and does not change the permanent TransMove tables. The statements in `benchmark_index_experiment.sql` must run in order within one pgAdmin Query Tool database session.

### 4.1 Rare status value: `Pending`

| Measurement | Before index | After index |
|---|---:|---:|
| Plan | Sequential Scan | Index Scan |
| Rows returned | 500 | 500 |
| Execution time | 10.528 ms | 0.252 ms |

In these two executions, PostgreSQL changed from a sequential scan to an index scan after the status index was created. The measured execution time was lower in the indexed run. This is an observed result from this test, not a guarantee for every workload or repeated run.

### 4.2 Common status value: `Delivered`

With PostgreSQL's normal planner settings, the query returned 99,500 rows using a Sequential Scan. Its recorded execution time was 16.093 ms.

For comparison, `enable_seqscan` was temporarily set to `OFF` to discourage sequential scans. PostgreSQL then used the status index and returned the same 99,500 rows. The recorded execution time was 15.228 ms. The plan's estimated cost for the forced index scan was higher than the sequential-scan plan.

This single pair of timings does not establish that the forced index scan performs better. The difference is small, cache and run-order effects can influence timings, and the planner estimated the forced index plan as more costly. The experiment demonstrates that an index scan can still be selected when explicitly encouraged, even when most rows match. PostgreSQL's normal plan should not be overridden based on one timing comparison.

## 5. Findings

1. PostgreSQL used the unique tracking-code index for the individual shipment lookup.
2. PostgreSQL chose sequential scanning for the status filter on the original three-row shipment table. For a table this small, scanning the rows directly is reasonable.
3. Refreshing table statistics improved the shipment row estimate from around 110 to three in the observed join plan.
4. In the larger benchmark, the status index changed the `Pending` lookup from a sequential scan to an index scan.
5. For the common `Delivered` value, PostgreSQL's normal planner chose a sequential scan because nearly every row matched. The forced-index test showed why a plan should be assessed using both estimated cost and repeated measurements, rather than assuming every index is beneficial.

## 6. Evidence

Execution-plan screenshots are stored in the `evidence/` directory. The screenshots record the plans and timings observed in pgAdmin. The corresponding SQL statements are in `baseline_queries.sql` and `benchmark_index_experiment.sql`.

## 7. Reproducibility note

The benchmark table is temporary. It exists only for the database session in which it was created and is removed when that session ends. To repeat the benchmark, run `benchmark_index_experiment.sql` from the beginning in one Query Tool session.
