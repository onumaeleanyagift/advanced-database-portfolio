-- MIT 8103 Advanced Database Systems
-- Portfolio 1: Database Design and Modelling
-- Case study: TransMove Logistics
-- Purpose: Insert fictional demonstration records into an already-created schema.
--
-- Run this after schema.sql has been successfully executed on a clean database.
-- This script uses conflict handling to reduce duplicate records if rerun.
-- It does not drop or delete existing data.

BEGIN;

-- 1. Depots
INSERT INTO depots (depot_name, city, address, contact_phone)
VALUES
    ('Lagos Depot', 'Lagos', 'Apapa, Lagos', '08030000001'),
    ('Abuja Depot', 'Abuja', 'Garki, Abuja', '08030000002'),
    ('Kano Depot', 'Kano', 'Kano Municipal', '08030000003')
ON CONFLICT (depot_name) DO NOTHING;

-- 2. Trucks
INSERT INTO trucks
    (registration_number, model, capacity_kg, truck_status, current_depot_id)
VALUES
    ('ABC-123-XY', 'Toyota Dyna', 3500, 'Assigned',
        (SELECT depot_id FROM depots WHERE depot_name = 'Lagos Depot')),
    ('DEF-456-XY', 'Isuzu NQR', 5000, 'Assigned',
        (SELECT depot_id FROM depots WHERE depot_name = 'Abuja Depot')),
    ('GHI-789-XY', 'Mitsubishi Fuso', 7000, 'In Maintenance',
        (SELECT depot_id FROM depots WHERE depot_name = 'Kano Depot'))
ON CONFLICT (registration_number) DO NOTHING;

-- 3. Drivers
INSERT INTO drivers
    (full_name, phone, licence_number, licence_expiry_date, driver_status)
VALUES
    ('Chinedu Okafor', '08040000001', 'LIC-TRM-001', DATE '2027-12-31', 'Assigned'),
    ('Amina Bello', '08040000002', 'LIC-TRM-002', DATE '2028-06-30', 'Assigned'),
    ('Musa Ibrahim', '08040000003', 'LIC-TRM-003', DATE '2027-04-30', 'Available')
ON CONFLICT (licence_number) DO NOTHING;

-- 4. Customers. The .example domain is reserved for documentation examples.
INSERT INTO customers (customer_name, phone, email, address)
VALUES
    ('FreshMart Ltd', '08050000001', 'ops@freshmart.example', 'Ikeja, Lagos'),
    ('ColdChain Supplies', '08050000002', 'dispatch@coldchain.example', 'Garki, Abuja')
ON CONFLICT DO NOTHING;

-- 5. Shipments
INSERT INTO shipments
    (tracking_code, customer_id, origin_depot_id, destination_address,
     created_at, weight_kg, shipment_status)
VALUES
    ('TRM-2026-0001',
        (SELECT customer_id FROM customers WHERE email = 'ops@freshmart.example'),
        (SELECT depot_id FROM depots WHERE depot_name = 'Lagos Depot'),
        'Ikeja, Lagos', TIMESTAMPTZ '2026-10-27 08:00:00+01', 450, 'Assigned'),
    ('TRM-2026-0002',
        (SELECT customer_id FROM customers WHERE email = 'dispatch@coldchain.example'),
        (SELECT depot_id FROM depots WHERE depot_name = 'Abuja Depot'),
        'Kaduna, Kaduna State', TIMESTAMPTZ '2026-10-27 08:30:00+01', 800, 'In Transit'),
    ('TRM-2026-0003',
        (SELECT customer_id FROM customers WHERE email = 'ops@freshmart.example'),
        (SELECT depot_id FROM depots WHERE depot_name = 'Kano Depot'),
        'Kano, Kano State', TIMESTAMPTZ '2026-10-27 09:00:00+01', 250, 'Pending')
ON CONFLICT (tracking_code) DO NOTHING;

-- 6. Delivery assignments
-- These two assignments are intentionally active to demonstrate the status rules.
INSERT INTO delivery_assignments
    (shipment_id, truck_id, driver_id, assigned_at, started_at,
     completed_at, assignment_status)
VALUES
    ((SELECT shipment_id FROM shipments WHERE tracking_code = 'TRM-2026-0001'),
     (SELECT truck_id FROM trucks WHERE registration_number = 'ABC-123-XY'),
     (SELECT driver_id FROM drivers WHERE licence_number = 'LIC-TRM-001'),
     TIMESTAMPTZ '2026-10-27 08:00:00+01', NULL, NULL, 'Assigned'),
    ((SELECT shipment_id FROM shipments WHERE tracking_code = 'TRM-2026-0002'),
     (SELECT truck_id FROM trucks WHERE registration_number = 'DEF-456-XY'),
     (SELECT driver_id FROM drivers WHERE licence_number = 'LIC-TRM-002'),
     TIMESTAMPTZ '2026-10-27 08:30:00+01',
     TIMESTAMPTZ '2026-10-27 09:00:00+01', NULL, 'In Transit')
ON CONFLICT DO NOTHING;

-- 7. Maintenance record for the truck assigned to Kano Depot
INSERT INTO maintenance_records
    (truck_id, service_date, description, cost, next_service_date, maintenance_status)
SELECT
    t.truck_id,
    DATE '2026-10-26',
    'Brake inspection and scheduled servicing',
    185000.00,
    DATE '2027-01-26',
    'In Progress'
FROM trucks t
WHERE t.registration_number = 'GHI-789-XY'
  AND NOT EXISTS (
      SELECT 1
      FROM maintenance_records m
      WHERE m.truck_id = t.truck_id
        AND m.service_date = DATE '2026-10-26'
        AND m.description = 'Brake inspection and scheduled servicing'
  );

-- 8. Vehicle devices
INSERT INTO vehicle_devices
    (truck_id, device_type, device_identifier, device_status, installation_date)
SELECT
    t.truck_id,
    v.device_type,
    v.device_identifier,
    'Active',
    DATE '2026-08-01'
FROM (
    VALUES
        ('ABC-123-XY', 'GPS Tracker', 'GPS-TR001'),
        ('ABC-123-XY', 'Temperature Sensor', 'TEMP-TR001'),
        ('ABC-123-XY', 'Driver Tablet', 'TAB-TR001'),
        ('DEF-456-XY', 'GPS Tracker', 'GPS-TR002'),
        ('DEF-456-XY', 'Temperature Sensor', 'TEMP-TR002'),
        ('DEF-456-XY', 'Driver Tablet', 'TAB-TR002')
) AS v(registration_number, device_type, device_identifier)
JOIN trucks t ON t.registration_number = v.registration_number
ON CONFLICT (device_identifier) DO NOTHING;

COMMIT;

-- Optional verification after commit: expected counts for a clean demo database
SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL SELECT 'delivery_assignments', COUNT(*) FROM delivery_assignments
UNION ALL SELECT 'depots', COUNT(*) FROM depots
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'maintenance_records', COUNT(*) FROM maintenance_records
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'trucks', COUNT(*) FROM trucks
UNION ALL SELECT 'vehicle_devices', COUNT(*) FROM vehicle_devices
ORDER BY table_name;
