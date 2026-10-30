-- MIT 8103: Advanced Database Systems
-- Portfolio 2: Indexing benchmark
-- Case study: TransMove Logistics
--
-- This experiment uses a TEMP table with 100,000 simulated shipment rows.
-- Run the statements in order in ONE pgAdmin Query Tool session.
-- The temporary table is removed when that database session ends.
-- No permanent TransMove Logistics tables are changed.

-- 1. Create the temporary benchmark data.
CREATE TEMP TABLE shipment_status_benchmark AS
SELECT
    g AS benchmark_id,
    'TRM-BENCH-' || LPAD(g::text, 6, '0') AS tracking_code,
    CASE
        WHEN g % 200 = 0 THEN 'Pending'
        ELSE 'Delivered'
    END AS shipment_status
FROM generate_series(1, 100000) AS g;

ANALYZE shipment_status_benchmark;

-- Expected distribution: 500 Pending rows and 99,500 Delivered rows.
SELECT shipment_status, COUNT(*) AS record_count
FROM shipment_status_benchmark
GROUP BY shipment_status
ORDER BY shipment_status;

-- 2. Rare status lookup BEFORE the index.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT benchmark_id, tracking_code, shipment_status
FROM shipment_status_benchmark
WHERE shipment_status = 'Pending';

-- 3. Create the index and refresh statistics.
CREATE INDEX idx_shipment_status_benchmark_status
ON shipment_status_benchmark (shipment_status);

ANALYZE shipment_status_benchmark;

-- 4. Repeat the same rare status lookup AFTER the index.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT benchmark_id, tracking_code, shipment_status
FROM shipment_status_benchmark
WHERE shipment_status = 'Pending';

-- 5. Common status lookup with PostgreSQL's normal planner settings.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT benchmark_id, tracking_code, shipment_status
FROM shipment_status_benchmark
WHERE shipment_status = 'Delivered';

-- 6. Controlled comparison: discourage sequential scans for this statement.
-- This is an experiment only, not a recommended permanent setting.
SET enable_seqscan = OFF;

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT benchmark_id, tracking_code, shipment_status
FROM shipment_status_benchmark
WHERE shipment_status = 'Delivered';

-- 7. Restore PostgreSQL's default setting for this parameter.
RESET enable_seqscan;
SHOW enable_seqscan;
