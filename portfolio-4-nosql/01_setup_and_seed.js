// MIT 8103: Advanced Database Systems
// Portfolio 4: NoSQL and Advanced Data Models
// TransMove Logistics (simulated)
// Run with mongosh. This script uses upserts so repeated runs do not duplicate seed records.

const transmoveDb = db.getSiblingDB("transmove_nosql");

if (!transmoveDb.getCollectionNames().includes("shipment_tracking")) {
  transmoveDb.createCollection("shipment_tracking");
}

if (!transmoveDb.getCollectionNames().includes("vehicle_telemetry")) {
  transmoveDb.createCollection("vehicle_telemetry");
}

const shipmentDocuments = [
  {
    shipmentId: 1,
    trackingCode: "TRM-2026-0001",
    customer: { customerId: 1, name: "FreshMart Ltd" },
    origin: { depotId: 1, depotName: "Lagos Depot", city: "Lagos" },
    destination: { address: "Ikeja, Lagos" },
    package: { weightKg: 450 },
    shipmentStatus: "Assigned",
    trackingEvents: [
      {
        status: "Created",
        description: "Shipment registered",
        eventTime: ISODate("2026-10-27T08:00:00Z")
      },
      {
        status: "Assigned",
        description: "Shipment assigned for delivery",
        eventTime: ISODate("2026-10-27T09:00:00Z")
      }
    ]
  },
  {
    shipmentId: 2,
    trackingCode: "TRM-2026-0002",
    customer: { customerId: 2, name: "ColdChain Supplies" },
    origin: { depotId: 2, depotName: "Abuja Depot", city: "Abuja" },
    destination: { address: "Kaduna, Kaduna State" },
    package: { weightKg: 800 },
    shipmentStatus: "In Transit",
    trackingEvents: [
      {
        status: "Created",
        description: "Shipment registered",
        eventTime: ISODate("2026-10-27T08:30:00Z")
      },
      {
        status: "In Transit",
        description: "Shipment dispatched",
        eventTime: ISODate("2026-10-27T09:00:00Z")
      }
    ]
  },
  {
    shipmentId: 3,
    trackingCode: "TRM-2026-0003",
    customer: { customerId: 1, name: "FreshMart Ltd" },
    origin: { depotId: 3, depotName: "Kano Depot", city: "Kano" },
    destination: { address: "Kano, Kano State" },
    package: { weightKg: 250 },
    shipmentStatus: "Pending",
    trackingEvents: [
      {
        status: "Created",
        description: "Shipment registered",
        eventTime: ISODate("2026-10-27T10:00:00Z")
      }
    ]
  }
];

for (const shipment of shipmentDocuments) {
  transmoveDb.shipment_tracking.updateOne(
    { trackingCode: shipment.trackingCode },
    { $setOnInsert: shipment },
    { upsert: true }
  );
}

const telemetryDocuments = [
  {
    truckRegistration: "ABC-123-XY",
    deviceType: "GPS Tracker",
    location: { latitude: 6.6018, longitude: 3.3515 },
    speedKph: 45,
    recordedAt: ISODate("2026-10-27T09:15:00Z")
  },
  {
    truckRegistration: "ABC-123-XY",
    deviceType: "GPS Tracker",
    location: { latitude: 6.6050, longitude: 3.3550 },
    speedKph: 52,
    recordedAt: ISODate("2026-10-27T09:20:00Z")
  },
  {
    truckRegistration: "DEF-456-XY",
    deviceType: "Temperature Sensor",
    temperatureC: 4.2,
    recordedAt: ISODate("2026-10-27T09:15:00Z")
  },
  {
    truckRegistration: "DEF-456-XY",
    deviceType: "Temperature Sensor",
    temperatureC: 4.5,
    recordedAt: ISODate("2026-10-27T09:20:00Z")
  },
  {
    truckRegistration: "GHI-789-XY",
    deviceType: "GPS Tracker",
    location: { latitude: 12.0022, longitude: 8.5919 },
    speedKph: 0,
    recordedAt: ISODate("2026-10-27T09:15:00Z")
  }
];

for (const reading of telemetryDocuments) {
  transmoveDb.vehicle_telemetry.updateOne(
    {
      truckRegistration: reading.truckRegistration,
      deviceType: reading.deviceType,
      recordedAt: reading.recordedAt
    },
    { $setOnInsert: reading },
    { upsert: true }
  );
}

print("Shipment documents:", transmoveDb.shipment_tracking.countDocuments());
print("Vehicle telemetry documents:", transmoveDb.vehicle_telemetry.countDocuments());
