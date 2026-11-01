// MIT 8103: Advanced Database Systems
// Portfolio 4: NoSQL and Advanced Data Models
// Indexes, JSON Schema validation, and integrity checks.

const transmoveDb = db.getSiblingDB("transmove_nosql");

// Unique index: one tracking code per shipment.
transmoveDb.shipment_tracking.createIndex(
  { trackingCode: 1 },
  { unique: true }
);

// Compound index: retrieve one vehicle's readings in time order.
transmoveDb.vehicle_telemetry.createIndex({
  truckRegistration: 1,
  recordedAt: 1
});

// Apply document validation to new inserts and updates.
transmoveDb.runCommand({
  collMod: "shipment_tracking",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "shipmentId",
        "trackingCode",
        "customer",
        "origin",
        "destination",
        "package",
        "shipmentStatus",
        "trackingEvents"
      ],
      properties: {
        shipmentId: { bsonType: ["int", "long", "double"] },
        trackingCode: { bsonType: "string" },
        customer: { bsonType: "object" },
        origin: { bsonType: "object" },
        destination: { bsonType: "object" },
        package: {
          bsonType: "object",
          required: ["weightKg"],
          properties: {
            weightKg: {
              bsonType: ["int", "long", "double"],
              minimum: 0
            }
          }
        },
        shipmentStatus: {
          bsonType: "string",
          enum: ["Pending", "Assigned", "In Transit", "Delivered", "Cancelled"]
        },
        trackingEvents: { bsonType: "array" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Review collection indexes and document counts.
print("Shipment indexes:");
printjson(transmoveDb.shipment_tracking.getIndexes());

print("Telemetry indexes:");
printjson(transmoveDb.vehicle_telemetry.getIndexes());

print("Shipment document count:", transmoveDb.shipment_tracking.countDocuments());
print("Telemetry document count:", transmoveDb.vehicle_telemetry.countDocuments());

// The following are intentional failure tests. Run each separately when needed.
// Duplicate tracking-code test: expected E11000 duplicate-key error.
/*
transmoveDb.shipment_tracking.insertOne({
  shipmentId: 99,
  trackingCode: "TRM-2026-0002",
  shipmentStatus: "Pending"
});
*/

// Invalid-status test: expected document validation failure because "Shipped" is not in the enum.
/*
transmoveDb.shipment_tracking.insertOne({
  shipmentId: 99,
  trackingCode: "TRM-INVALID-001",
  customer: { customerId: 1, name: "Test Customer" },
  origin: { depotId: 1, depotName: "Lagos Depot" },
  destination: { address: "Abuja" },
  package: { weightKg: 100 },
  shipmentStatus: "Shipped",
  trackingEvents: []
});
*/
