# MIT 8103: Advanced Database Systems Portfolio

**Academic session:** 2026/2027  
**Selected case study:** TransMove Logistics (simulated)

## Project overview

This repository contains the practical database portfolio for MIT 8103: Advanced Database Systems. The five portfolio activities use one consistent case study, TransMove Logistics, a simulated logistics company operating a fleet of 600 delivery trucks from depots in Lagos, Abuja and Kano.

The database scenario covers depots, trucks, drivers, customers, shipments, delivery assignments, vehicle maintenance and onboard devices. It supports operational tasks such as registering vehicles and customers, assigning drivers and trucks to shipments, tracking delivery status, recording maintenance and retrieving information for reporting.

All sample records used in the project are fictional and created for this academic exercise.

## Portfolio activities

| Portfolio | Focus | Current progress |
|---|---|---|
| Portfolio 1 | Database Design and Modelling | Implemented and documented. PostgreSQL schema, sample data, constraints, relationships, validation and ER diagram evidence are included. |
| Portfolio 2 | Query Processing and Optimisation | In progress. Baseline execution plans, query results and a 100,000-row temporary indexing benchmark have been tested. |
| Portfolio 3 | Transactions and Concurrency | Not started. |
| Portfolio 4 | NoSQL and Advanced Data Models | Not started. |
| Portfolio 5 | Distributed and Cloud Database Exercise | Not started. |

The progress descriptions will be updated as each activity is implemented and reviewed.

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

Each portfolio folder contains its own README, implementation files and supporting evidence where applicable. The README in each folder describes the work for that activity.

## Tools and technology

- PostgreSQL 18 for relational database implementation and query testing.
- pgAdmin 4 for database administration and SQL execution.
- SQL for schema creation, data manipulation, validation and query analysis.
- Git and GitHub for version control and progressive development commits.

The tools for the NoSQL and distributed/cloud activities will be documented in their respective portfolio folders when selected and implemented.

## Working with the repository

Start with the README inside the relevant portfolio folder. It explains the activity, its implementation files, tests and evidence.

For Portfolio 1, the `schema.sql` file contains the relational schema definition, `sample_data.sql` contains fictional sample records, and `validation_tests.sql` contains checks used during implementation. The schema script is intended to create the tables in a new, empty database. The Portfolio 1 README provides the database setup details.

For Portfolio 2, the SQL files contain the baseline queries and the temporary indexing benchmark. The benchmark table is temporary and must be recreated in the same pgAdmin Query Tool session before the experiment is repeated.

## Evidence and documentation

Screenshots, query outputs, execution plans, configuration details and other technical evidence are stored in the relevant portfolio's `evidence/` directory. Each portfolio README describes the evidence associated with that activity.

A separate 2–3 page portfolio summary, including the GitHub repository link, selected case study, technical reflection and required supporting references, will be submitted through the LMS in accordance with the assessment brief.

## AI use declaration

I used ChatGPT as a learning and development aid during this portfolio. It helped explain database concepts, plan the relational schema, draft and review SQL and documentation, and troubleshoot implementation issues. I ran the SQL in PostgreSQL through pgAdmin 4 and checked the resulting tables, relationships, constraints, query plans and outputs during the work. I remain responsible for the submitted work and for understanding and verifying the design decisions, scripts, analysis and evidence.

## References

- Miva Open University. *MIT 8103 Advanced Database Systems: First Semester Continuous Assessment, 2026/2027 Academic Session*.
- Miva Open University. *Advanced Database Systems* course notes, Master of Information Technology programme.
