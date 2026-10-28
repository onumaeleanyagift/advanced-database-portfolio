-- MIT 8103 Advanced Database Systems
-- Portfolio 1: Database Design and Modelling
-- Case study: TransMove Logistics
-- Database: transmove_logistics (PostgreSQL)
--
-- Purpose: Verify the schema, relationships, indexes, sample data and key rules.
-- Safety: The runnable statements below are SELECT queries and do not change data.
-- Run the sections one at a time in pgAdmin Query Tool and capture screenshots.
-- Do NOT rerun schema.sql against the existing database.

-- ============================================================
-- TEST 1: Confirm the eight portfolio tables exist
-- Expected: depots, trucks, drivers, customers, shipments,
-- delivery_assignments, maintenance_records, vehicle_devices.
-- ============================================================
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================================
-- TEST 2: Count the sample records in each table
-- Expected current counts: customers 2, delivery_assignments 2,
-- depots 3, drivers 3, maintenance_records 1, shipments 3,
-- trucks 3, vehicle_devices 6.
-- ============================================================
SELECT 'depots' AS table_name, COUNT(*) AS record_count FROM depots
UNION ALL
SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'delivery_assignments', COUNT(*) FROM delivery_assignments
UNION ALL
SELECT 'maintenance_records', COUNT(*) FROM maintenance_records
UNION ALL
SELECT 'vehicle_devices', COUNT(*) FROM vehicle_devices
ORDER BY table_name;

-- ============================================================
-- TEST 3: List foreign-key relationships
-- Expected: 8 foreign-key constraints.
-- ============================================================
SELECT
    tc.table_name AS child_table,
    kcu.column_name AS child_column,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
 AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.constraint_schema = tc.constraint_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY child_table, child_column;

-- ============================================================
-- TEST 4: List primary-key, unique, check and foreign-key constraints
-- Note: PostgreSQL may display NOT NULL rules separately in table metadata.
-- ============================================================
SELECT
    conrelid::regclass AS table_name,
    conname AS constraint_name,
    CASE contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
        WHEN 'f' THEN 'FOREIGN KEY'
        ELSE contype::text
    END AS constraint_type,
    pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
  AND conrelid <> 0
ORDER BY table_name::text, constraint_type, constraint_name;

-- ============================================================
-- TEST 5: Confirm indexes on delivery_assignments
-- Expected: delivery_assignments_pkey, uq_active_shipment,
-- uq_active_truck and uq_active_driver.
-- ============================================================
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'delivery_assignments'
ORDER BY indexname;

-- ============================================================
-- TEST 6: Retrieve shipment details by joining related tables
-- Expected: 3 shipment rows with customer and origin depot names.
-- ============================================================
SELECT
    s.tracking_code,
    c.customer_name,
    d.depot_name AS origin_depot,
    s.destination_address,
    s.weight_kg,
    s.shipment_status
FROM shipments AS s
JOIN customers AS c
  ON c.customer_id = s.customer_id
JOIN depots AS d
  ON d.depot_id = s.origin_depot_id
ORDER BY s.shipment_id;

-- ============================================================
-- TEST 7: Retrieve delivery assignment details across four tables
-- Expected: 2 assignment rows with tracking code, truck and driver.
-- ============================================================
SELECT
    da.assignment_id,
    s.tracking_code,
    t.registration_number,
    dr.full_name AS driver_name,
    da.assignment_status,
    da.assigned_at,
    da.started_at,
    da.completed_at
FROM delivery_assignments AS da
JOIN shipments AS s
  ON s.shipment_id = da.shipment_id
JOIN trucks AS t
  ON t.truck_id = da.truck_id
JOIN drivers AS dr
  ON dr.driver_id = da.driver_id
ORDER BY da.assignment_id;

-- ============================================================
-- TEST 8: Check for data-quality violations
-- Expected: every issue_count should be 0.
-- ============================================================
SELECT 'Trucks with non-positive capacity' AS test_name, COUNT(*) AS issue_count
FROM trucks
WHERE capacity_kg <= 0
UNION ALL
SELECT 'Shipments with non-positive weight', COUNT(*)
FROM shipments
WHERE weight_kg <= 0
UNION ALL
SELECT 'Maintenance with negative cost', COUNT(*)
FROM maintenance_records
WHERE cost < 0
UNION ALL
SELECT 'Shipments with missing customer', COUNT(*)
FROM shipments AS s
LEFT JOIN customers AS c ON c.customer_id = s.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Shipments with missing origin depot', COUNT(*)
FROM shipments AS s
LEFT JOIN depots AS d ON d.depot_id = s.origin_depot_id
WHERE d.depot_id IS NULL
UNION ALL
SELECT 'Assignments with missing shipment, truck or driver', COUNT(*)
FROM delivery_assignments AS da
LEFT JOIN shipments AS s ON s.shipment_id = da.shipment_id
LEFT JOIN trucks AS t ON t.truck_id = da.truck_id
LEFT JOIN drivers AS dr ON dr.driver_id = da.driver_id
WHERE s.shipment_id IS NULL
   OR t.truck_id IS NULL
   OR dr.driver_id IS NULL
UNION ALL
SELECT 'Duplicate active shipment assignments', COUNT(*)
FROM (
    SELECT shipment_id
    FROM delivery_assignments
    WHERE assignment_status IN ('Assigned', 'In Transit')
    GROUP BY shipment_id
    HAVING COUNT(*) > 1
) AS duplicates
UNION ALL
SELECT 'Duplicate active truck assignments', COUNT(*)
FROM (
    SELECT truck_id
    FROM delivery_assignments
    WHERE assignment_status IN ('Assigned', 'In Transit')
    GROUP BY truck_id
    HAVING COUNT(*) > 1
) AS duplicates
UNION ALL
SELECT 'Duplicate active driver assignments', COUNT(*)
FROM (
    SELECT driver_id
    FROM delivery_assignments
    WHERE assignment_status IN ('Assigned', 'In Transit')
    GROUP BY driver_id
    HAVING COUNT(*) > 1
) AS duplicates
ORDER BY test_name;

-- ============================================================
-- TEST 9: Deliberate CHECK-constraint test (NOT RUN by default)
-- To demonstrate that the database rejects invalid truck capacity,
-- select and run this INSERT by itself. It is expected to fail with
-- a violation of trucks_capacity_kg_check (SQLSTATE 23514).
-- Do not include this INSERT when running the read-only tests above.
-- ============================================================
-- INSERT INTO trucks (
--     registration_number,
--     model,
--     capacity_kg,
--     truck_status,
--     current_depot_id
-- )
-- VALUES (
--     'TEST-VALIDATION-001',
--     'Test Truck',
--     0,
--     'Available',
--     (SELECT depot_id FROM depots WHERE depot_name = 'Lagos Depot')
-- );
