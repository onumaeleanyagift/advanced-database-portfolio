// Run once while connected directly to Node 1 on port 27018.
// Example: mongosh "mongodb://localhost:27018/?directConnection=true" --file .\02_initiate_replica_set.js

rs.initiate({
  _id: 'rsTransMove',
  members: [
    { _id: 0, host: 'localhost:27018', priority: 2 },
    { _id: 1, host: 'localhost:27019' },
    { _id: 2, host: 'localhost:27020' }
  ]
});
