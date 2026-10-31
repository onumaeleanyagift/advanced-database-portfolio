# Transaction and Concurrency Analysis

## Case study

The experiments use the TransMove Logistics shipment scenario. A separate table, `shipment_transaction_lab`, provides a working copy of the shipment records so that transaction tests do not modify the original `shipments` table.

## Transaction commit

The first transaction changed shipment `TRM-2026-0003` from `Pending` to `Assigned`. PostgreSQL returned the updated row, and the `COMMIT` command completed successfully. A subsequent query returned `Assigned`, confirming that the change persisted.

## Transaction rollback

A later transaction temporarily changed the same shipment to `Delivered`. The transaction was rolled back before a commit. The follow-up query returned `Assigned`, showing that PostgreSQL discarded the uncommitted update and preserved the last committed value.

## READ COMMITTED

Two separate pgAdmin Query Tool sessions were used. Session A began a transaction at `READ COMMITTED` and first read the shipment status as `Assigned`. Session B changed the status to `In Transit` and committed. When Session A repeated the SELECT within its still-open transaction, it saw `In Transit`.

This is a non-repeatable read: two executions of the same query within one transaction returned different committed values. PostgreSQL's `READ COMMITTED` isolation level takes a fresh snapshot for each statement.

## REPEATABLE READ

Session A began a transaction at `REPEATABLE READ` and read the shipment status as `In Transit`. Session B changed the status to `Assigned` and committed. Session A repeated the SELECT but continued to see `In Transit` while its transaction remained open.

After Session A committed and started a new transaction for its next query, it saw `Assigned`. This demonstrates the consistent snapshot provided by PostgreSQL's `REPEATABLE READ` isolation level for the duration of the transaction.

## Row-level locking

Session A selected shipment `TRM-2026-0003` using `SELECT ... FOR UPDATE`. This acquired a row-level lock and held it until the transaction ended. While that lock remained active, Session B attempted to update the same shipment to `Delivered`. Session B's UPDATE waited.

After Session A committed and released the lock, Session B's waiting UPDATE completed. Session B then committed the change. The final query was expected to return `Delivered`.

## Overall observations

The exercises demonstrate how PostgreSQL handles transaction boundaries, uncommitted changes, statement-level snapshots, transaction-level snapshots, and conflicting updates to the same row. The two-session tests used separate pgAdmin connections with different backend process IDs.

The transaction lab is a test copy. The original `shipments` table was not used for these updates. The setup script copies the current shipment values into the lab table; rerunning it synchronises the lab records with the source table and can reset values changed during the experiments. The setup script should therefore be run before the exercises, not between them.
