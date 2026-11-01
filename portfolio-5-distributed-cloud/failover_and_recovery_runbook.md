# Failover and Recovery Runbook

This runbook records the order used for the TransMove Logistics replica-set exercise.

## Before the test

1. Start the three local `mongod` processes with `01_start_replica_nodes.ps1`.
2. Initialise the replica set once with `02_initiate_replica_set.js` from Node 1 (`localhost:27018`).
3. Wait for one PRIMARY and two SECONDARY members. Check with `03_check_replica_set_status.js` or `rs.status()`.
4. Insert `replica-check-001` through the PRIMARY with `04_primary_replication_write.js`.
5. Connect to Node 2 using a secondary read preference and confirm the document with `05_read_from_secondary.js`.

## Simulate primary failure

1. Connect directly to Node 1:

   ```powershell
   & "$env:LOCALAPPDATA\Programs\mongosh\mongosh.exe" "mongodb://localhost:27018/?directConnection=true"
   ```

2. At the MongoDB Shell prompt, stop Node 1:

   ```javascript
   db.adminCommand({ shutdown: 1 })
   ```

3. The shell connection closes. In this lab, `mongosh` displayed `MongoNetworkError: read ECONNRESET` after the server shut down. That connection reset is expected when the connected server stops.
4. Connect directly to Node 2 (`localhost:27019`) and wait for the election to finish. Check `rs.status()`. In the observed test, Node 2 became PRIMARY and Node 3 remained SECONDARY.
5. Run `06_write_after_failover.js` against the new PRIMARY. The insert used `{ w: 'majority', wtimeout: 10000 }`.
6. Connect directly to Node 3 with `readPreference=secondary` and run `07_read_failover_write_from_secondary.js`. The observed result contained `failover-write-001`.

## Recover the original primary

1. Run `01_start_replica_nodes.ps1` again. It checks the three ports and starts only members that are not already listening. Node 1 should start using its existing `node1` data directory.
2. Wait for Node 1 to rejoin and synchronise.
3. Check `rs.status()` from a member. In the observed test, Node 1 rejoined and became PRIMARY again because its configured priority was 2. Nodes 2 and 3 returned to SECONDARY.
4. Read `failover-write-001` from Node 3 to confirm the post-failover write is present on a secondary after recovery.

## Notes

- Do not run `rs.initiate()` again on an already initialised replica set.
- Do not delete or reuse a node's data directory during the recovery test.
- Keep Nodes 2 and 3 running while Node 1 is offline; the replica set needs a voting majority to elect a primary.
- All three members in this exercise ran on the same Windows computer. This is a process-level failover demonstration, not a test of host-level or site-level disaster recovery.
