// Connect directly to a SECONDARY after the failover write has replicated.
// Example:
// mongosh "mongodb://localhost:27020/?directConnection=true&readPreference=secondary" --file .\07_read_failover_write_from_secondary.js

const result = db.getSiblingDB('transmove_distributed')
  .replication_checks
  .findOne({ _id: 'failover-write-001' });

printjson(result);
