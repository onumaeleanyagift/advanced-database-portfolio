// Connect directly to a SECONDARY before running this file.
// Example:
// mongosh "mongodb://localhost:27019/?directConnection=true&readPreference=secondary" --file .\05_read_from_secondary.js

const result = db.getSiblingDB('transmove_distributed')
  .replication_checks
  .findOne({ _id: 'replica-check-001' });

printjson(result);
