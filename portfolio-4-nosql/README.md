# Portfolio 4: NoSQL and Advanced Data Models

**Case study:** TransMove Logistics (simulated)  
**Database:** MongoDB Server 9.0.4  
**Shell:** MongoDB Shell 2.14.1  
**Environment:** Windows 11 with a local MongoDB service

## Activity

This portfolio applies MongoDB's document data model to the TransMove Logistics case study. It stores shipment details and related tracking events as embedded documents, while vehicle GPS and temperature readings are stored as separate telemetry documents.

The implementation covers document insertion and retrieval, queries against nested fields and arrays, aggregation pipelines, single-field and compound indexes, unique-key enforcement, document validation, and updates to embedded arrays.

## Database and collections

Database: `transmove_nosql`

| Collection | Document purpose | Model choice |
|---|---|---|
| `shipment_tracking` | Shipment, customer snapshot, origin depot snapshot, destination, package details, status, and tracking events | Customer, depot, package, and tracking events are embedded in each shipment document. |
| `vehicle_telemetry` | Individual GPS or temperature sensor readings associated with a truck and timestamp | Each reading is a separate document. GPS and temperature documents can have different fields. |

Tracking events are embedded because they are normally read with the shipment and form part of its tracking history. Telemetry readings are separate because a vehicle can produce many readings over time, and keeping them separate avoids an indefinitely growing array inside a shipment document.

## Main implementation work

- Inserted three shipment documents with embedded customer, depot, package, and tracking-event data.
- Queried a shipment by its tracking code and queried an embedded tracking-event array using dot notation.
- Inserted five simulated telemetry documents containing GPS and temperature readings.
- Filtered and sorted temperature readings and queried nested GPS latitude values.
- Created a unique ascending index on `shipment_tracking.trackingCode`.
- Created a compound index on `vehicle_telemetry.truckRegistration` and `recordedAt`.
- Inspected query plans with `explain("executionStats")`.
- Used aggregation pipelines to summarise shipments by status and temperature readings by truck.
- Updated a shipment and appended a tracking event using `$set` and `$push`.
- Added a `$jsonSchema` validator and confirmed that an invalid shipment status was rejected.
- Attempted a duplicate tracking code and confirmed that the unique index rejected it.
- Verified that the collections contained three shipment documents and five telemetry documents after the rejected insert.

## Files

- `01_setup_and_seed.js` — creates the collections if needed and inserts the sample documents without duplicating existing seed records.
- `02_queries_and_aggregations.js` — shipment and telemetry queries, aggregation pipelines, and execution-plan examples.
- `03_indexes_and_validation.js` — index creation, collection validation, and integrity checks. The two intentionally failing test inserts are commented out so the script can run without stopping on expected errors.
- `04_update_embedded_tracking_event.js` — updates a shipment and appends a tracking event. The update filter avoids appending the same event a second time if the script is rerun.
- `nosql_analysis.md` — design rationale, observations from the implementation, measured execution-plan details, and limitations.
- `evidence/` — screenshots supporting the MongoDB setup, queries, indexes, aggregation, validation, and integrity checks.

## Evidence

The `evidence/` directory contains the following implementation screenshots:

1. `01_mongodb_connection_and_collections.jpeg`
2. `02_shipment_documents_inserted.jpeg`
3. `03_shipment_lookup.jpeg`
4. `04_embedded_tracking_event_query.jpeg`
5. `05_vehicle_telemetry_inserted.jpeg`
6. `06_vehicle_telemetry_query.jpeg`
7. `07_shipment_tracking_index.jpeg`
8. `08_mongodb_index_execution_plan.jpeg`
9. `09_duplicate_tracking_code_rejected.jpeg`
10. `10_shipment_status_aggregation.jpeg`
11. `11_vehicle_temperature_aggregation.jpeg`
12. `12_embedded_tracking_event_update.jpeg`
13. `13_vehicle_telemetry_compound_index.jpeg`
14. `14_telemetry_index_execution_plan.jpeg`
15. `15_gps_location_filter.jpeg`
16. `16_mongodb_document_validation.jpeg`
17. `17_invalid_shipment_rejected.jpeg`
18. `18_collection_integrity_verification.jpeg`

## Environment and data notes

The implementation ran against a local MongoDB Server 9.0.4 instance using MongoDB Shell 2.14.1. The connection shown during testing was to `127.0.0.1:27017`.

The shipment and telemetry records are simulated data for this academic exercise. The GPS coordinates and sensor readings are illustrative and do not represent live vehicle tracking.

The local MongoDB instance displayed a startup warning that access control was not enabled. This exercise used a local development instance; it was not configured for access from an external network.
