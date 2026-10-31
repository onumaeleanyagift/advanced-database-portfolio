-- MIT 8103: Advanced Database Systems
-- Portfolio 3: Transactions and Concurrency
-- Case study: TransMove Logistics
-- Database: PostgreSQL
--
-- IMPORTANT:
-- This file documents experiments that were executed across two pgAdmin Query Tool sessions.

/* -------------------------------------------------------------------------
   1. COMMIT DEMONSTRATION
   Run in either session when no other transaction is open.
   ------------------------------------------------------------------------- */

BEGIN;

UPDATE shipment_transaction_lab
SET
    shipment_status = 'Assigned',
    updated_at = CURRENT_TIMESTAMP
WHERE tracking_code = 'TRM-2026-0003'
RETURNING shipment_id, tracking_code, shipment_status;

COMMIT;

-- Verify the committed value.
SELECT shipment_id, tracking_code, shipment_status, updated_at
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';


/* -------------------------------------------------------------------------
   2. ROLLBACK DEMONSTRATION
   Run after the COMMIT demonstration.
   ------------------------------------------------------------------------- */

BEGIN;

UPDATE shipment_transaction_lab
SET
    shipment_status = 'Delivered',
    updated_at = CURRENT_TIMESTAMP
WHERE tracking_code = 'TRM-2026-0003'
RETURNING shipment_id, tracking_code, shipment_status;

-- ROLLBACK reverses the uncommitted update.
ROLLBACK;

-- The status should remain at the last committed value: Assigned.
SELECT shipment_id, tracking_code, shipment_status, updated_at
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';


/* -------------------------------------------------------------------------
   3. READ COMMITTED: NON-REPEATABLE READ DEMONSTRATION
   Keep Session A's transaction open while Session B updates and commits.
   ------------------------------------------------------------------------- */

-- SESSION A: run first and leave the transaction open.
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- Expected initial value in the recorded exercise: Assigned.

-- SESSION B: run while Session A remains open.
BEGIN;

UPDATE shipment_transaction_lab
SET
    shipment_status = 'In Transit',
    updated_at = CURRENT_TIMESTAMP
WHERE tracking_code = 'TRM-2026-0003'
RETURNING shipment_id, tracking_code, shipment_status;

COMMIT;

-- SESSION A: run the same SELECT again before committing Session A.
SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- Under READ COMMITTED, the second statement sees Session B's committed value.

-- SESSION A: finish the transaction.
COMMIT;


/* -------------------------------------------------------------------------
   4. REPEATABLE READ: CONSISTENT SNAPSHOT DEMONSTRATION
   Keep Session A's transaction open while Session B updates and commits.
   ------------------------------------------------------------------------- */

-- SESSION A: start a new transaction after the READ COMMITTED exercise ends.
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- Expected initial value in the recorded exercise: In Transit.

-- SESSION B: update and commit while Session A remains open.
BEGIN;

UPDATE shipment_transaction_lab
SET
    shipment_status = 'Assigned',
    updated_at = CURRENT_TIMESTAMP
WHERE tracking_code = 'TRM-2026-0003'
RETURNING shipment_id, tracking_code, shipment_status;

COMMIT;

-- SESSION A: repeat the SELECT before committing Session A.
SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- Under REPEATABLE READ, Session A continues to see its transaction snapshot.

-- SESSION A: end the transaction, then run a new SELECT.
COMMIT;

SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- The new transaction sees Session B's committed value: Assigned.


/* -------------------------------------------------------------------------
   5. ROW-LEVEL LOCKING WITH SELECT FOR UPDATE
   Session B's UPDATE waits until Session A releases the row lock.
   ------------------------------------------------------------------------- */

-- SESSION A: acquire the row lock and leave the transaction open.
BEGIN;

SELECT shipment_id, tracking_code, shipment_status
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003'
FOR UPDATE;

-- SESSION B: execute while Session A holds the lock. This UPDATE waits.
BEGIN;

UPDATE shipment_transaction_lab
SET
    shipment_status = 'Delivered',
    updated_at = CURRENT_TIMESTAMP
WHERE tracking_code = 'TRM-2026-0003'
RETURNING shipment_id, tracking_code, shipment_status;

-- SESSION A: release the row lock.
COMMIT;

-- SESSION B: its waiting UPDATE can now complete. Commit it after it returns.
COMMIT;

-- Verify the final committed value.
SELECT shipment_id, tracking_code, shipment_status, updated_at
FROM shipment_transaction_lab
WHERE tracking_code = 'TRM-2026-0003';
-- Expected final value after the recorded exercise: Delivered.
