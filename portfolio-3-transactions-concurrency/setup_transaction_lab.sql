-- MIT 8103: Advanced Database Systems
-- Portfolio 3: Transactions and Concurrency
-- TransMove Logistics
-- Creates a separate working copy of shipment data for transaction experiments.

CREATE TABLE IF NOT EXISTS shipment_transaction_lab (
    shipment_id BIGINT PRIMARY KEY,
    tracking_code VARCHAR(50) NOT NULL UNIQUE,
    shipment_status VARCHAR(20) NOT NULL,
    weight_kg NUMERIC(10,2) NOT NULL CHECK (weight_kg > 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Synchronise the lab copy with the current shipment records.
-- This allows the setup script to be rerun without creating duplicate rows.
INSERT INTO shipment_transaction_lab (
    shipment_id,
    tracking_code,
    shipment_status,
    weight_kg,
    updated_at
)
SELECT
    shipment_id,
    tracking_code,
    shipment_status,
    weight_kg,
    CURRENT_TIMESTAMP
FROM shipments
ON CONFLICT (shipment_id) DO UPDATE
SET
    tracking_code = EXCLUDED.tracking_code,
    shipment_status = EXCLUDED.shipment_status,
    weight_kg = EXCLUDED.weight_kg,
    updated_at = CURRENT_TIMESTAMP;

-- Display the records available for the transaction experiments.
SELECT
    shipment_id,
    tracking_code,
    shipment_status,
    weight_kg,
    updated_at
FROM shipment_transaction_lab
ORDER BY shipment_id;
