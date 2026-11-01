// Run once while connected to the current PRIMARY.
// This inserts the initial document used to verify replication on a secondary.

const result = db.getSiblingDB('transmove_distributed')
  .replication_checks
  .insertOne(
    {
      _id: 'replica-check-001',
      system: 'TransMove Logistics',
      purpose: 'Replica set replication test',
      createdAt: new Date()
    },
    {
      writeConcern: {
        w: 'majority',
        wtimeout: 10000
      }
    }
  );

printjson(result);
