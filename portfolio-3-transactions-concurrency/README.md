# Portfolio 3: Transactions and Concurrency

**Case study:** TransMove Logistics (simulated)  
**Database:** PostgreSQL 18  
**Tool:** pgAdmin 4

## Activity

This portfolio examines transaction control and concurrent access to shipment records. A separate `shipment_transaction_lab` table holds a working copy of the source shipment data so the experiments do not change the original `shipments` table.

The implementation demonstrates `COMMIT`, `ROLLBACK`, the `READ COMMITTED` and `REPEATABLE READ` isolation levels, and row-level locking with `SELECT FOR UPDATE` across two independent PostgreSQL sessions.

## Files

- `setup_transaction_lab.sql` — Creates and populates the transaction test table from the TransMove shipment records.
- `transaction_experiments.sql` — SQL statements used for the transaction, isolation, and locking demonstrations. The session-specific blocks are run separately in Session A and Session B.
- `transaction_analysis.md` — Explanation of the observed transaction behaviour and results.
- `evidence/` — pgAdmin screenshots supporting the implementation and experiments.

## Implementation summary

- A committed update changed shipment `TRM-2026-0003` from `Pending` to `Assigned`.
- A later uncommitted update to `Delivered` was rolled back. The committed `Assigned` value remained.
- Under `READ COMMITTED`, Session A first read `Assigned`. After Session B committed `In Transit`, Session A's next SELECT saw `In Transit` within the same transaction.
- Under `REPEATABLE READ`, Session A continued to see `In Transit` after Session B committed `Assigned`. After Session A ended its transaction, a new query saw `Assigned`.
- With `SELECT FOR UPDATE`, Session A held a row-level lock. Session B's update to `Delivered` waited until Session A committed. Session B then completed and committed its update.

## Running the experiments

Run `setup_transaction_lab.sql` once before the transaction exercises. It creates a separate test table and synchronises it with the source `shipments` table. Rerunning the setup script can reset the test table to the current source shipment values, so it should not be rerun between experiments.

For isolation and locking demonstrations, use two separate pgAdmin Query Tool connections to the same `transmove_logistics` database. Run the Session A and Session B blocks in the order described in `transaction_experiments.sql`. Keep each transaction open until the corresponding step instructs you to commit or roll it back.

## Evidence

The `evidence/` directory contains screenshots of the lab setup, committed and rolled-back changes, the two isolation-level experiments, and the row-locking sequence.
