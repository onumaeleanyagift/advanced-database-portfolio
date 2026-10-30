# Portfolio 2: Query Processing and Optimisation

**Case study:** TransMove Logistics (simulated)  
**Database:** PostgreSQL 18  
**Tool:** pgAdmin 4

## Activity

This portfolio examines query execution plans for shipment lookups, status filters, and joins across shipments, customers, and depots. PostgreSQL's `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` output provides the execution-plan and timing evidence.

A separate 100,000-row temporary benchmark table supports a controlled comparison of status filtering before and after adding an index. The benchmark also compares PostgreSQL's normal plan for a common status value with a plan produced while sequential scans are discouraged.

## Files

- `baseline_queries.sql` — the three queries tested against the TransMove Logistics database.
- `benchmark_index_experiment.sql` — SQL to recreate and repeat the temporary indexing experiment.
- `query_performance_analysis.md` — recorded execution plans, measurements, observations, and limitations.
- `evidence/` — pgAdmin screenshots of the execution plans, query timings, actual query results, and benchmark comparisons.

## Main observations

- PostgreSQL used the unique tracking-code index for a single-shipment lookup.
- PostgreSQL selected a sequential scan for the status filter on the small case-study table.
- Refreshing statistics with `ANALYZE` brought the shipment row estimate in line with the actual three rows in the join test.
- In the 100,000-row benchmark, an index scan was selected for the status value that matched 500 rows.
- PostgreSQL's normal planner selected a sequential scan for the status value that matched 99,500 rows.
- Discouraging sequential scans produced an index scan for the common status value, allowing a comparison with PostgreSQL's normal plan.

The recorded timings come from individual test runs. They are evidence of the observed behaviour, not universal performance guarantees. The temporary benchmark table must be recreated in one pgAdmin Query Tool session before the experiment is repeated.
