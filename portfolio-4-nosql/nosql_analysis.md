# Portfolio 4: NoSQL Implementation Analysis

## 1. Document model

The implementation uses two MongoDB collections in `transmove_nosql`.

- `shipment_tracking` stores each shipment as one document. Customer and depot details are embedded as snapshots, package information is nested, and shipment tracking events are stored in an embedded array.
- `vehicle_telemetry` stores one sensor reading per document. GPS readings contain a nested `location` object and `speedKph`; temperature readings contain `temperatureC`. The documents therefore share collection-level identity and query fields while supporting different sensor-specific attributes.

Embedding shipment-related information makes a shipment and its tracking history available in one document read. It also avoids a relational join for this access pattern. Customer and depot snapshots can become duplicated across shipments, so updates to master customer or depot details would need a deliberate consistency strategy. Telemetry is separate because a vehicle may produce a large number of readings; keeping an unbounded reading history inside one shipment document would make that document grow continuously.

## 2. Insertions and query results

Three shipment documents were inserted:

| Tracking code | Customer | Origin | Status | Weight |
|---|---|---|---|---:|
| TRM-2026-0001 | FreshMart Ltd | Lagos Depot | Assigned initially; later updated to In Transit | 450 kg |
| TRM-2026-0002 | ColdChain Supplies | Abuja Depot | In Transit | 800 kg |
| TRM-2026-0003 | FreshMart Ltd | Kano Depot | Pending | 250 kg |

Five simulated telemetry documents were inserted: two GPS readings for `ABC-123-XY`, two temperature readings for `DEF-456-XY`, and one GPS reading for `GHI-789-XY`.

A lookup by `trackingCode` returned the complete `TRM-2026-0002` document, including its embedded customer, origin, destination, package, and tracking events. A dot-notation query on `trackingEvents.status` returned that shipment because one embedded event had status `In Transit`.

The temperature query for `DEF-456-XY` returned two readings (4.2°C and 4.5°C) in ascending timestamp order. A nested-field query using `location.latitude > 10` returned the `GHI-789-XY` GPS reading with latitude 12.0022.

## 3. Aggregation results

The shipment aggregation grouped documents by `shipmentStatus` and calculated count, total package weight, and average package weight.

| Status | Shipment count | Total weight | Average weight |
|---|---:|---:|---:|
| Assigned | 1 | 450 kg | 450 kg |
| In Transit | 1 | 800 kg | 800 kg |
| Pending | 1 | 250 kg | 250 kg |

The temperature aggregation for `DEF-456-XY` returned an average of 4.35°C, a minimum of 4.2°C, a maximum of 4.5°C, and two readings.

## 4. Indexes and execution plans

A unique ascending index named `trackingCode_1` was created on `shipment_tracking.trackingCode`. Its uniqueness option prevents duplicate tracking codes. The execution-stats output for the `TRM-2026-0002` lookup showed an `EXPRESS_IXSCAN` winning stage using `trackingCode_1`; it returned one document, examined one index key, and examined one document. The reported execution time was 26 ms in that run.

A compound ascending index named `truckRegistration_1_recordedAt_1` was created on `vehicle_telemetry` using `truckRegistration` followed by `recordedAt`. The query for `DEF-456-XY` sorted by `recordedAt` used an `IXSCAN` on that compound index. It returned two documents, examined two keys and two documents, and reported 18 ms in that run.

The collections contain only three shipment documents and five telemetry documents. These plans demonstrate that MongoDB selected the intended indexes, but the small sample does not support a reliable claim of a material performance improvement. The timings are individual observations and will vary between runs and environments.

## 5. Updates and validation

The shipment update used `$set` to change `TRM-2026-0001` to `In Transit` and set `updatedAt`. It used `$push` to append a dispatch event to the embedded `trackingEvents` array. The operation reported `matchedCount: 1` and `modifiedCount: 1`; the subsequent lookup showed the new status and event.

A collection-level `$jsonSchema` validator was applied to `shipment_tracking` with strict validation and error handling. It requires the shipment's main fields, checks key BSON types, requires `package.weightKg` to be non-negative, and restricts `shipmentStatus` to `Pending`, `Assigned`, `In Transit`, `Delivered`, or `Cancelled`.

An attempted insertion with status `Shipped` was rejected with `Document failed validation`; the error identified the `shipmentStatus` enum rule. A separate duplicate insertion using tracking code `TRM-2026-0002` was rejected with error `E11000` by the unique index. The final count checks returned three documents in `shipment_tracking` and five in `vehicle_telemetry`, confirming that neither rejected test increased the collection counts.

## 6. Suitability and limitations

The document model suits shipment tracking because the application often retrieves the shipment together with its customer, origin, destination, and event history. Embedding these related values supports a single-document read and makes event updates straightforward. A flexible telemetry collection suits different device payloads, such as GPS coordinates and temperature readings, without requiring every document to have identical sensor fields.

The design also has trade-offs. Embedded customer and depot snapshots duplicate values. Embedded tracking-event arrays need a retention or archival approach if they grow substantially. Telemetry volume will grow quickly in a live fleet, so production deployment would need retention policies, time-based partitioning or a time-series collection design, and capacity planning. Those production-scale features were not implemented in this portfolio.

## 7. Environment and reproducibility

The work was run locally on Windows using MongoDB Server 9.0.4 and MongoDB Shell 2.14.1, connected to `127.0.0.1:27017`. The collections and documents use simulated TransMove Logistics data; GPS coordinates and sensor readings are illustrative, not live telemetry.

The local server displayed a startup warning that access control was not enabled. The exercise used a local development instance. It was not exposed as a network service. A deployed system would require authentication, authorization, network restrictions, and suitable operational controls.
