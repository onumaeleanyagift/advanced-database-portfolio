// Run once while connected to the newly elected PRIMARY after Node 1 is shut down.

const result = db.getSiblingDB('transmove_distributed')
  .replication_checks
  .insertOne(
    {
      _id: 'failover-write-001',
      system: 'TransMove Logistics',
      purpose: 'Write test after primary failover',
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
