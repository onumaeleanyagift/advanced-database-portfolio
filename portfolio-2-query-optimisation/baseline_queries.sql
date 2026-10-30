-- MIT 8103: Advanced Database Systems
-- Portfolio 2: Query Processing and Optimisation
-- TransMove Logistics
-- Baseline query plans before adding any new indexes.
-- Run against the existing transmove_logistics database in pgAdmin.

-- 1. Lookup a shipment by its tracking code.
-- tracking_code is already UNIQUE in the schema, so PostgreSQL has an index for it.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT shipment_id, tracking_code, shipment_status, weight_kg
FROM shipments
WHERE tracking_code = 'TRM-2026-0002';

-- 2. Filter shipments by status.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT shipment_id, tracking_code, shipment_status, weight_kg
FROM shipments
WHERE shipment_status = 'In Transit';

-- 3. Join shipments with customers and depots, filtering by shipment status.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    s.tracking_code,
    c.customer_name,
    d.depot_name,
    s.destination_address,
    s.shipment_status
FROM shipments AS s
JOIN customers AS c
    ON s.customer_id = c.customer_id
JOIN depots AS d
    ON s.origin_depot_id = d.depot_id
ORDER BY s.created_at DESC;

-- Note for analysis:
-- This database currently contains only a few sample records. PostgreSQL may choose

-- sequential scans even where indexes exist, because scanning a tiny table can be
-- cheaper than using an index. That is normal; do not claim an index improved
-- performance unless the measured plans and timings support that conclusion.
