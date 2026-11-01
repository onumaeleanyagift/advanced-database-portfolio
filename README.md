# MIT 8103: Advanced Database Systems Portfolio

**Academic session:** 2026/2027, First Semester  
**Selected case study:** TransMove Logistics (simulated)

## Project overview

This repository contains the practical database portfolio for MIT 8103: Advanced Database Systems. All five portfolio activities use the same case study: TransMove Logistics, a simulated logistics company operating a fleet of 600 delivery trucks from depots in Lagos, Abuja and Kano.

The system supports dispatch officers, depot managers, fleet managers and authorised administrative staff. It stores information about depots, trucks, drivers, customers, shipments, delivery assignments, maintenance records and onboard devices. Its main operations include registering customers and vehicles, assigning trucks and drivers to shipments, updating delivery statuses, recording maintenance, capturing vehicle telemetry and producing operational reports.

The sample records, customer details, tracking events, GPS coordinates and sensor readings are fictional and were created for this academic exercise.

## Portfolio activities

| Portfolio | Focus | Work completed |
|---|---|---|
| **Portfolio 1** | Database Design and Modelling | Designed and implemented the PostgreSQL relational schema with eight related tables. Documented the ER diagram, relational structure, primary and foreign keys, constraints, indexes and normalisation. Inserted fictional sample data and tested relationships and data-integrity rules. |
| **Portfolio 2** | Query Processing and Optimisation | Tested shipment lookups, status filters and joins using `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)`. Reviewed query plans and planner estimates, and ran a separate 100,000-row temporary benchmark to compare index scans and sequential scans for different status selectivities. |
| **Portfolio 3** | Transactions and Concurrency | Used a separate transaction lab table to demonstrate `COMMIT`, `ROLLBACK`, `READ COMMITTED`, `REPEATABLE READ` and row-level locking with `SELECT FOR UPDATE` across two PostgreSQL sessions. Verified the resulting transaction states. |
| **Portfolio 4** | NoSQL and Advanced Data Models | Implemented MongoDB collections for shipment tracking and vehicle telemetry. Used embedded shipment and tracking-event documents, nested-field queries, aggregation pipelines, unique and compound indexes, and JSON Schema validation. Tested duplicate-key and invalid-document rejection. |
| **Portfolio 5** | Distributed and Cloud Database Exercise | Configured a three-member MongoDB replica set, tested replication to secondary members, stopped the original primary, verified automatic primary election and writes after failover, then restarted the original member and checked recovery. Sharding and multi-host cloud deployment are discussed as design options, not implemented configurations. |

## Repository structure

```text
advanced-database-portfolio/
├── README.md
├── portfolio-1-database-design/
├── portfolio-2-query-optimisation/
├── portfolio-3-transactions-concurrency/
├── portfolio-4-nosql/
└── portfolio-5-distributed-cloud/
```

Each portfolio folder contains its own README, implementation files and supporting evidence. Refer to the README inside a portfolio folder for the activity-specific instructions, tests, results and limitations.

## Tools and technology

| Area | Tools and technology |
|---|---|
| Relational database | PostgreSQL 18, SQL and pgAdmin 4 |
| NoSQL database | MongoDB Server 9.0.4 and MongoDB Shell 2.14.1 |
| Distributed database lab | MongoDB replica set with three local `mongod` processes on Windows 11 |
| Version control | Git and GitHub |
| Setup and execution | SQL scripts, MongoDB JavaScript (`.js`) scripts and a Windows PowerShell (`.ps1`) setup script for the local replica-set lab |

## Running the work

Start with the README in the relevant portfolio folder. It describes the files to run, the required database or session, and the evidence captured during testing.

### Portfolio 1: Database Design and Modelling

The `schema.sql` file defines the relational tables, keys, relationships, constraints and indexes. The `sample_data.sql` file inserts fictional records. Use the setup instructions in the Portfolio 1 README and run the schema against a new, empty PostgreSQL database. Do not rerun the table-creation script against an already populated database unless the instructions specifically explain how to reset it.

### Portfolio 2: Query Processing and Optimisation

The baseline query script contains the three case-study queries and their execution-plan statements. The separate indexing benchmark uses a temporary benchmark table with 100,000 simulated rows. Recreate that temporary table in the same pgAdmin Query Tool session before repeating the benchmark, because temporary tables are session-scoped.

### Portfolio 3: Transactions and Concurrency

The transaction exercises use a separate lab table and two independent PostgreSQL sessions. Follow the order in the Portfolio 3 README when repeating the isolation and row-lock tests. Some results depend on the timing and sequence of commands across both sessions.

### Portfolio 4: NoSQL and Advanced Data Models

The MongoDB scripts create and query the `transmove_nosql` database and its `shipment_tracking` and `vehicle_telemetry` collections. Review the Portfolio 4 README before running setup or seed scripts so that existing sample documents and indexes are handled as intended.

### Portfolio 5: Distributed and Cloud Database Exercise

The replica-set lab uses three MongoDB server processes on one Windows 11 computer, with ports `27018`, `27019` and `27020`. The PowerShell script starts the local members. The MongoDB JavaScript files initialise the replica set and demonstrate replication, failover and recovery. Follow the runbook in the Portfolio 5 folder. Keep the three data directories separate and do not reuse the data directory of the existing MongoDB service on port `27017`.

The replica-set demonstration is a local development lab. Because all three members run on one computer, it demonstrates member-level replication and election but does not protect against failure of the computer itself. The lab also used loopback binding and did not enable database access control. It is not a production security or high-availability deployment. Sharding and multi-host cloud deployment are considered in the technical analysis but were not configured as part of the practical test.

## Evidence and documentation

Screenshots, query outputs, execution plans, configuration details, logs and test results are stored in the relevant portfolio's `evidence/` directory. Each portfolio README identifies the evidence associated with its activity. The implementation scripts and analysis documents provide the steps and interpretation behind the screenshots.

The separate 2–3 page portfolio summary is submitted through the LMS. It describes the selected case study and all five activities, includes the GitHub repository link, and provides an individual technical reflection, references and an AI-use declaration.

## AI use declaration

ChatGPT was used as a learning and development aid to explain database concepts, discuss design options, draft and review scripts and documentation, and help troubleshoot implementation issues. The SQL and MongoDB commands were run in the local PostgreSQL and MongoDB environments. The resulting tables, relationships, constraints, query plans, transaction outcomes, document counts, validation errors, replica-set states and replication reads were checked against the implementations. The submitted work remains the student's responsibility, including its accuracy and the ability to explain the design choices, scripts, results and limitations.

## References

- Miva Open University. *MIT 8103 Advanced Database Systems: First Semester Continuous Assessment, 2026/2027 Academic Session*.
- Miva Open University. *Advanced Database Systems* course notes, Master of Information Technology programme.
- PostgreSQL Global Development Group. *PostgreSQL 18 Documentation*. https://www.postgresql.org/docs/18/
- MongoDB, Inc. *MongoDB Manual*. https://www.mongodb.com/docs/manual/