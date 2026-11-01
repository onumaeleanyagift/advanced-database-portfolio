# Portfolio 5: Distributed and Cloud Database Exercise

**Case study:** TransMove Logistics (simulated)  
**Database:** MongoDB Server 9.0.4  
**Shell:** MongoDB Shell 2.14.1  
**Environment:** Windows 11, local three-member replica set

## Activity

This portfolio demonstrates MongoDB replication, replica-set elections, primary failover, recovery, and majority write acknowledgement using the TransMove Logistics case study.

A three-member replica set named `rsTransMove` was configured with separate data directories and ports on one Windows computer. Node 1 used a higher election priority than Nodes 2 and 3. The experiment inserted documents through the primary, read replicated documents from secondary members, shut down the original primary, verified the election of a replacement primary, wrote data after failover, and restarted the original primary.

## Replica-set topology

| Member | Address | Configured priority | Observed role after recovery |
|---|---|---:|---|
| Node 1 | `localhost:27018` | 2 | PRIMARY |
| Node 2 | `localhost:27019` | 1 (default) | SECONDARY |
| Node 3 | `localhost:27020` | 1 (default) | SECONDARY |

All three members reported `health: 1` after recovery. When Node 1 was stopped, Node 2 became PRIMARY and Node 3 remained SECONDARY. After Node 1 restarted, it rejoined and later became PRIMARY again. This matched the configured priority behaviour in this test.

## Files

- `01_start_replica_nodes.ps1` — creates the three data directories and starts any replica-set processes that are not already listening.
- `02_initiate_replica_set.js` — initialises `rsTransMove` with three members and Node 1 priority 2. Run only once for a new replica set.
- `03_check_replica_set_status.js` — reports member states and the connected member's primary status.
- `04_primary_replication_write.js` — inserts the initial replication test document using majority write concern.
- `05_read_from_secondary.js` — reads the initial document from a secondary.
- `06_write_after_failover.js` — inserts a second test document after a secondary becomes primary.
- `07_read_failover_write_from_secondary.js` — reads the post-failover write from a secondary.
- `failover_and_recovery_runbook.md` — step-by-step sequence for the shutdown, election, write, and recovery test.
- `distributed_database_analysis.md` — implementation results, design considerations, limitations, and proposed cloud/sharding design.
- `evidence/` — screenshots supporting the implementation and test results.

## Evidence

The `evidence/` directory contains the pgAdmin-free MongoDB Shell and PowerShell screenshots for this activity. The evidence filenames used for this portfolio are:

1. `01_replica_nodes_listening.jpeg`
2. `02_replica_set_healthy.jpeg`
3. `03_primary_document_insert.jpeg`
4. `04_secondary_replication_read.jpeg`
5. `05_primary_failover_election.jpeg`
6. `06_write_after_failover.jpeg`
7. `07_replication_after_failover.jpeg`
8. `08_node1_rejoined_and_data_present.jpeg`
9. `09_replica_set_restored.jpeg`
10. `10_failover_write_visible_on_secondary.jpeg`

## Important implementation limits

The three `mongod` processes ran on one Windows computer and listened on `127.0.0.1`/`localhost`. This demonstrates replica-set replication and process-level failover. It does **not** demonstrate resilience to failure of the computer, its operating system, its disk, or its network connection. A production deployment would place members on separate hosts and failure domains.

The startup output also reported that access control was not enabled. This local lab was bound to loopback addresses and was not configured as a production service. Do not expose these instances to a network. A real deployment requires authentication, internal member authentication, TLS, private network access controls, backups, and monitoring.

Sharding and cloud deployment are discussed as design considerations in `distributed_database_analysis.md`; they were not configured in this practical implementation.
