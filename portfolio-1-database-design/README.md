# MIT 8103 – Portfolio 1: Database Design and Modelling

## Case Study: TransMove Logistics

### 1. Overview

TransMove Logistics is a simulated logistics company operating a fleet of 600 delivery trucks from depots in Lagos, Abuja and Kano. The company transports shipments for different customers and needs a database to manage its depots, trucks, drivers, customers, shipments, delivery assignments, vehicle maintenance and onboard devices.

The database is intended for use by dispatch officers, depot managers, fleet managers and authorised administrative staff. It supports registering operational records, assigning trucks and drivers to shipments, tracking shipment status, maintaining vehicles and retrieving information for operational reporting.

This is a simulated case study created for the MIT 8103 Advanced Database Systems practical portfolio. Sample records are fictional.

### 2. Database technology

- **DBMS:** PostgreSQL 18 (confirm the exact installed version with `SELECT version();`)
- **Database name:** `transmove_logistics`
- **Database tool:** pgAdmin 4
- **Schema:** `public`

### 3. Tables and purpose

| Table | Purpose |
|---|---|
| `depots` | Stores depot names, locations and contact details. |
| `trucks` | Stores vehicle registration, model, capacity, status and current depot. |
| `drivers` | Stores driver details, licence number, expiry date and status. |
| `customers` | Stores customer contact details. |
| `shipments` | Stores shipment tracking code, customer, origin depot, destination, weight and status. |
| `delivery_assignments` | Records the truck and driver assigned to each shipment, including assignment timestamps and status. |
| `maintenance_records` | Stores vehicle servicing and repair history. |
| `vehicle_devices` | Stores information about GPS trackers, temperature sensors and driver tablets installed on trucks. |

### 4. Relationships

The design uses primary keys to identify records and foreign keys to link related tables.

- One depot can be the current depot for many trucks; each truck references one current depot.
- One customer can have many shipments; each shipment references one customer.
- One depot can be the origin depot for many shipments.
- One shipment can have multiple delivery-assignment records over time to preserve reassignment history.
- Each delivery assignment references one shipment, one truck and one driver.
- One truck can have many maintenance records.
- One truck can have multiple vehicle devices.

The `delivery_assignments` table is separate from `shipments` so that assignment changes can be recorded without overwriting previous assignment records. The current implementation assumes each assignment covers one shipment, one truck and one driver.

### 5. Keys and constraints

The database uses the following controls:

- **Primary keys:** Each table has an identifier, such as `truck_id`, `shipment_id` or `customer_id`.
- **Foreign keys:** These connect trucks to depots, shipments to customers and origin depots, assignments to shipments/trucks/drivers, and maintenance/devices to trucks.
- **Unique constraints:** These prevent duplicate values for fields such as depot names, truck registration numbers, driver licence numbers, shipment tracking codes and device identifiers. Customer email is also unique when supplied.
- **Not-null constraints:** These require key operational values to be present.
- **Check constraints:** These enforce rules such as positive truck capacity and shipment weight, non-negative maintenance cost, permitted status values, and valid assignment/service date sequences.
- **Partial unique indexes:** `uq_active_shipment`, `uq_active_truck` and `uq_active_driver` are designed to prevent a shipment, truck or driver from being involved in more than one assignment with status `Assigned` or `In Transit` at the same time.

### 6. Normalisation

Normalisation was considered to reduce unnecessary duplication and help prevent insertion, update and deletion anomalies.

**First Normal Form (1NF):** Each field stores one value rather than a list. For example, each device is stored as an individual record in `vehicle_devices`, rather than storing multiple device identifiers in a single truck field.

**Second Normal Form (2NF):** The tables use single-column primary keys, so partial dependencies on part of a composite primary key do not arise. Attributes are assigned to the table representing the entity they describe.

**Third Normal Form (3NF):** Non-key attributes are stored with the entity they describe. For example, depot names and addresses are kept in `depots`, while `trucks` stores `current_depot_id` as a reference. Customer contact details are kept in `customers`, while `shipments` references `customer_id`.

### 7. Implementation and tests completed

The following implementation checks have been carried out in pgAdmin 4:

1. Created the eight tables listed above.
2. Queried `information_schema` to confirm that the eight tables exist.
3. Queried the database catalog to inspect foreign-key relationships.
4. Inspected primary-key, unique and check constraints.
5. Inspected the indexes on `delivery_assignments`.
6. Inserted fictional sample data: 3 depots, 3 trucks, 3 drivers, 2 customers, 3 shipments, 2 delivery assignments, 1 maintenance record and 6 vehicle devices.
7. Joined `shipments` to `customers` and `depots` to display shipment details.
8. Joined `delivery_assignments` to `shipments`, `trucks` and `drivers` to display assignments.
9. Tested a truck insert with `capacity_kg = 0`. PostgreSQL rejected it with check-constraint violation `trucks_capacity_kg_check` (SQLSTATE `23514`), confirming that the positive-capacity rule is enforced.

The ER diagram should be saved with all table relationship lines visible. Confirm the final exported image or screenshot before including it in the submission.

### 8. Evidence to include

Place the evidence files in an `evidence/` directory and use these filenames where applicable:

- `01_database_tables.jpeg` – query showing all eight tables
- `02_table_structure.jpeg` – `trucks` table columns and data types
- `03_foreign_keys.jpeg` – query showing foreign-key relationships
- `04_constraints.jpeg` – summary of primary-key, foreign-key, unique and check constraints
- `05_indexes.jpeg` – indexes on `delivery_assignments`
- `06_record_counts.jpeg` – row counts for all eight tables
- `07_shipment_query.jpeg` – shipment/customer/depot join result
- `08_delivery_assignments.jpeg` – shipment/truck/driver assignment join result
- `09_validation_test.jpeg` – rejected insert showing the check-constraint error
- `10_erd_diagram.jpeg` – ER diagram with readable tables and relationship lines

Only list evidence files here after you have saved and checked them. Do not include screenshots that are missing or unreadable.

### 9. Files to keep in this portfolio folder

- `README.md` – this documentation
- `schema.sql` – the table and index creation statements
- `sample_data.sql` – the fictional sample data insert statements
- `validation_tests.sql` – queries and constraint tests
- `evidence/` – implementation screenshots and the ER diagram

### 10. Technical reflection

The main design decision was to separate operational entities into related tables and use keys to preserve their relationships. Keeping customer and depot details in their own tables reduces repeated data, while the assignment table preserves the history of which truck and driver handled a shipment. The constraints also demonstrate how database rules can prevent some invalid records from being stored. During implementation, the database rejected a truck with zero capacity, which verified that the check constraint worked as intended.

The next improvements would be to document query execution plans and indexing decisions, test transactions and concurrency, implement a suitable NoSQL model for sensor readings, and explore replication or cloud deployment in the later portfolio activities.

### 11. AI-use declaration

AI assistance was used to help explain database design concepts, plan the schema, draft SQL and documentation, and troubleshoot implementation steps. The SQL was run in pgAdmin and the results were checked during implementation. The student remains responsible for reviewing the work, understanding each design choice, verifying the final scripts and ensuring that all submitted evidence accurately reflects their own database.

### 12. References

- Miva Open University. *MIT 8103 Advanced Database Systems: First Semester Continuous Assessment, 2026/2027 Academic Session*. Assessment brief.
- Miva Open University. *Advanced Database Systems* course notes, MIT programme.
