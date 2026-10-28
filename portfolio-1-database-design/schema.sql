-- MIT 8103 Advanced Database Systems
-- Portfolio 1: Database Design and Modelling
-- Case study: TransMove Logistics
-- DBMS: PostgreSQL
--
-- This is the schema-creation script for a NEW, EMPTY database.

-- 1. Depots
CREATE TABLE depots (
    depot_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    depot_name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL,
    address VARCHAR(200),
    contact_phone VARCHAR(25)
);

-- 2. Trucks
CREATE TABLE trucks (
    truck_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_number VARCHAR(20) NOT NULL UNIQUE,
    model VARCHAR(80) NOT NULL,
    capacity_kg NUMERIC(10, 2) NOT NULL
        CHECK (capacity_kg > 0),
    truck_status VARCHAR(20) NOT NULL DEFAULT 'Available'
        CHECK (truck_status IN (
            'Available',
            'Assigned',
            'In Maintenance',
            'Retired'
        )),
    current_depot_id BIGINT NOT NULL,
    CONSTRAINT fk_truck_depot
        FOREIGN KEY (current_depot_id)
        REFERENCES depots(depot_id)
        ON DELETE RESTRICT
);

-- 3. Drivers
CREATE TABLE drivers (
    driver_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(25),
    licence_number VARCHAR(40) NOT NULL UNIQUE,
    licence_expiry_date DATE NOT NULL,
    driver_status VARCHAR(20) NOT NULL DEFAULT 'Available'
        CHECK (driver_status IN (
            'Available',
            'Assigned',
            'On Leave',
            'Inactive'
        ))
);

-- 4. Customers
CREATE TABLE customers (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(150) UNIQUE,
    address VARCHAR(250)
);

-- 5. Shipments
CREATE TABLE shipments (
    shipment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tracking_code VARCHAR(30) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    origin_depot_id BIGINT NOT NULL,
    destination_address VARCHAR(250) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    weight_kg NUMERIC(10, 2) NOT NULL
        CHECK (weight_kg > 0),
    shipment_status VARCHAR(25) NOT NULL DEFAULT 'Pending'
        CHECK (shipment_status IN (
            'Pending',
            'Assigned',
            'In Transit',
            'Delivered',
            'Cancelled'
        )),
    CONSTRAINT fk_shipment_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shipment_origin_depot
        FOREIGN KEY (origin_depot_id)
        REFERENCES depots(depot_id)
        ON DELETE RESTRICT
);

-- 6. Delivery assignments
CREATE TABLE delivery_assignments (
    assignment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    truck_id BIGINT NOT NULL,
    driver_id BIGINT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    assignment_status VARCHAR(25) NOT NULL DEFAULT 'Assigned'
        CHECK (assignment_status IN (
            'Assigned',
            'In Transit',
            'Completed',
            'Cancelled',
            'Reassigned'
        )),
    CONSTRAINT fk_assignment_shipment
        FOREIGN KEY (shipment_id)
        REFERENCES shipments(shipment_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_assignment_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_assignment_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_assignment_start
        CHECK (
            started_at IS NULL OR started_at >= assigned_at
        ),
    CONSTRAINT chk_assignment_completion
        CHECK (
            completed_at IS NULL OR
            (started_at IS NOT NULL AND completed_at >= started_at)
        )
);

-- 7. Maintenance records
CREATE TABLE maintenance_records (
    maintenance_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    truck_id BIGINT NOT NULL,
    service_date DATE NOT NULL,
    description TEXT NOT NULL,
    cost NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (cost >= 0),
    next_service_date DATE,
    maintenance_status VARCHAR(25) NOT NULL DEFAULT 'Scheduled'
        CHECK (maintenance_status IN (
            'Scheduled',
            'In Progress',
            'Completed',
            'Cancelled'
        )),
    CONSTRAINT fk_maintenance_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_next_service_date
        CHECK (
            next_service_date IS NULL OR next_service_date >= service_date
        )
);

-- 8. Vehicle devices
CREATE TABLE vehicle_devices (
    device_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    truck_id BIGINT NOT NULL,
    device_type VARCHAR(30) NOT NULL
        CHECK (device_type IN (
            'GPS Tracker',
            'Temperature Sensor',
            'Driver Tablet'
        )),
    device_identifier VARCHAR(100) NOT NULL UNIQUE,
    device_status VARCHAR(25) NOT NULL DEFAULT 'Active'
        CHECK (device_status IN (
            'Active',
            'Inactive',
            'Faulty',
            'Under Maintenance'
        )),
    installation_date DATE NOT NULL,
    CONSTRAINT fk_device_truck
        FOREIGN KEY (truck_id)
        REFERENCES trucks(truck_id)
        ON DELETE RESTRICT
);

-- Partial unique indexes: only one active assignment per shipment, truck or driver.
CREATE UNIQUE INDEX uq_active_shipment
ON delivery_assignments (shipment_id)
WHERE assignment_status IN ('Assigned', 'In Transit');

CREATE UNIQUE INDEX uq_active_truck
ON delivery_assignments (truck_id)
WHERE assignment_status IN ('Assigned', 'In Transit');

CREATE UNIQUE INDEX uq_active_driver
ON delivery_assignments (driver_id)
WHERE assignment_status IN ('Assigned', 'In Transit');
