// MIT 8103: Advanced Database Systems
// Portfolio 4: NoSQL and Advanced Data Models
// Query and aggregation examples for the transmove_nosql database.

const transmoveDb = db.getSiblingDB("transmove_nosql");

// 1. Retrieve a shipment by its tracking code.
transmoveDb.shipment_tracking.findOne({
  trackingCode: "TRM-2026-0002"
});

// 2. Find shipments with an embedded tracking event whose status is In Transit.
transmoveDb.shipment_tracking.find(
  { "trackingEvents.status": "In Transit" },
  {
    _id: 0,
    trackingCode: 1,
    shipmentStatus: 1,
    trackingEvents: 1
  }
).pretty();

// 3. Retrieve temperature readings for one truck, in time order.
transmoveDb.vehicle_telemetry.find(
  {
    truckRegistration: "DEF-456-XY",
    deviceType: "Temperature Sensor"
  },
  {
    _id: 0,
    truckRegistration: 1,
    deviceType: 1,
    temperatureC: 1,
    recordedAt: 1
  }
).sort({ recordedAt: 1 }).pretty();

// 4. Summarise shipment count and package weight by shipment status.
transmoveDb.shipment_tracking.aggregate([
  {
    $group: {
      _id: "$shipmentStatus",
      totalShipments: { $sum: 1 },
      totalWeightKg: { $sum: "$package.weightKg" },
      averageWeightKg: { $avg: "$package.weightKg" }
    }
  },
  { $sort: { _id: 1 } }
]);

// 5. Summarise temperature readings by truck.
transmoveDb.vehicle_telemetry.aggregate([
  { $match: { deviceType: "Temperature Sensor" } },
  {
    $group: {
      _id: "$truckRegistration",
      averageTemperature: { $avg: "$temperatureC" },
      minimumTemperature: { $min: "$temperatureC" },
      maximumTemperature: { $max: "$temperatureC" },
      totalReadings: { $sum: 1 }
    }
  }
]);

// 6. Find GPS readings where latitude is greater than 10.
transmoveDb.vehicle_telemetry.find(
  {
    deviceType: "GPS Tracker",
    "location.latitude": { $gt: 10 }
  },
  {
    _id: 0,
    truckRegistration: 1,
    location: 1,
    speedKph: 1,
    recordedAt: 1
  }
).pretty();

// 7. Inspect the tracking-code lookup plan and execution statistics.
transmoveDb.shipment_tracking.find({
  trackingCode: "TRM-2026-0002"
}).explain("executionStats");

// 8. Inspect the vehicle/time compound-index query plan.
transmoveDb.vehicle_telemetry.find({
  truckRegistration: "DEF-456-XY"
}).sort({ recordedAt: 1 }).explain("executionStats");
