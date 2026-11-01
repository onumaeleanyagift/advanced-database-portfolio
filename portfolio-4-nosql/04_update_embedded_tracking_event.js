// MIT 8103: Advanced Database Systems
// Portfolio 4: NoSQL and Advanced Data Models
// Update one shipment and append its dispatch event once.

const transmoveDb = db.getSiblingDB("transmove_nosql");

const dispatchDescription = "Shipment dispatched from Lagos Depot";

const result = transmoveDb.shipment_tracking.updateOne(
  {
    trackingCode: "TRM-2026-0001",
    "trackingEvents.description": { $ne: dispatchDescription }
  },
  {
    $set: {
      shipmentStatus: "In Transit",
      updatedAt: new Date()
    },
    $push: {
      trackingEvents: {
        status: "In Transit",
        description: dispatchDescription,
        eventTime: new Date()
      }
    }
  }
);

printjson(result);
printjson(transmoveDb.shipment_tracking.findOne({
  trackingCode: "TRM-2026-0001"
}));
