# Distributed Database Analysis: TransMove Logistics

## 1. Implementation

A three-member MongoDB replica set named `rsTransMove` was configured on a Windows 11 computer using MongoDB Server 9.0.4 and MongoDB Shell 2.14.1.

| Member | Address | Priority | Observed steady-state role after recovery |
|---|---|---:|---|
| Node 1 | `localhost:27018` | 2 | PRIMARY |
| Node 2 | `localhost:27019` | 1 (default) | SECONDARY |
| Node 3 | `localhost:27020` | 1 (default) | SECONDARY |

Each member used a separate data directory under `%USERPROFILE%\mongodb-replica-lab`. The existing MongoDB Windows service on port 27017 was left running and was not used as a replica-set member.

## 2. Replication results

The initial test document `replica-check-001` was inserted through the primary with majority write concern. A read directed to Node 2, configured with `readPreference=secondary`, returned the same document.

This showed that the write from the primary had been replicated to a secondary. The majority write concern requested acknowledgement from a majority of replica-set members before the write was reported as successful.

## 3. Failover and recovery results

Node 1 was shut down with `db.adminCommand({ shutdown: 1 })`. The shell connection then closed with `ECONNRESET`, which was the expected effect of shutting down the server to which the shell was connected.

After the election, the observed member states were:

| Member | State while Node 1 was unavailable |
|---|---|
| Node 1 | Not reachable; health 0 |
| Node 2 | PRIMARY; health 1 |
| Node 3 | SECONDARY; health 1 |

A second document, `failover-write-001`, was inserted through Node 2 using majority write concern. Node 3, while operating as a secondary, returned that document.

Node 1 was then restarted with its existing data directory. It rejoined the replica set. After recovery, all three members reported health 1. Node 1 became PRIMARY again, consistent with its configured priority of 2, while Nodes 2 and 3 were SECONDARY. The post-failover document was also retrieved from Node 3 after recovery.

## 4. Availability and consistency

The exercise demonstrated that the replica set could elect a replacement primary after one member stopped, accept a majority-acknowledged write through the replacement primary, and replicate that write to another member.

The experiment also used secondary reads. Secondary reads can return data that has not yet caught up with the latest primary write because replication is asynchronous. The test confirmed that the particular documents were visible on the selected secondaries; it does not prove that every secondary read is always current. For applications that require stronger read guarantees, read concern, read preference, and write concern must be selected to match the business requirement.

## 5. Sharding considerations

Sharding was not configured in this practical. The implemented distributed mechanism was replica-set replication, which maintains copies of the same data set. Sharding addresses a different requirement: horizontal distribution of a collection's data and workload across multiple shards.

For a future high-volume `vehicle_telemetry` collection, `truckRegistration` is a possible shard-key field because the application commonly filters readings by truck. A hashed form of this field could spread different trucks across shards. However, all readings for a single truck would still map to one hashed key value, so a fleet with one exceptionally active vehicle could create an uneven workload. A compound ranged key such as `{ truckRegistration: 1, recordedAt: 1 }` could support time-ordered queries for a truck, but key distribution and write patterns would need testing against real workloads. The final shard key should be selected from measured query patterns and data distribution, not assumed from this small sample.

A MongoDB sharded cluster would require more than the three replica-set members created here. The normal architecture includes replica-set shards, a config-server replica set, and one or more `mongos` query routers. Each shard is itself a replica set. The application connects through `mongos`, not directly to individual shard members.

## 6. Cloud deployment design

A production TransMove deployment could place the three replica-set members on separate virtual machines in separate availability zones or data centres. Each member would use a stable private DNS name and private network address. The replica-set configuration would advertise those reachable hostnames rather than `localhost`.

The deployment would also require authentication, internal member authentication (for example, a keyfile or X.509), TLS, network access restrictions, encrypted storage, backups, monitoring, and a tested recovery plan. A managed database service could reduce operational work, but the service configuration and consistency settings would still need to match the application's availability and recovery requirements.

No cloud provider, remote host, or managed MongoDB deployment was created for this exercise. The cloud section is a proposed design, not implementation evidence.

## 7. Limitations

All three `mongod` processes ran on one Windows computer and bound to `127.0.0.1`. The exercise demonstrates member-level failure and election behaviour, but it does not protect against failure of the computer, operating system, power supply, storage device, or local network. A host-level failure would take all three members offline together.

The server startup warning stated that access control was not enabled. The lab remained bound to loopback addresses and was used locally. This configuration must not be exposed to other machines or the public internet. Production deployment requires authentication and transport security before network access is enabled.

The sample documents and tests are simulated and small. They demonstrate the database mechanisms but do not provide a capacity, latency, or production-readiness benchmark.

## 8. Conclusion

The practical demonstrated MongoDB replica-set setup, replication to secondary members, primary election after a member shutdown, a majority-acknowledged write after failover, and recovery of the original primary. It also identified the limits of a single-host replica-set lab and outlined the additional infrastructure required for sharding and cloud deployment.

## References

- MongoDB Manual, Replication: https://www.mongodb.com/docs/manual/replication/
- MongoDB Manual, Replica Set Elections: https://www.mongodb.com/docs/manual/core/replica-set-elections/
- MongoDB Manual, Sharding: https://www.mongodb.com/docs/manual/sharding/
- MongoDB Manual, Sharded Cluster Components: https://www.mongodb.com/docs/manual/core/sharded-cluster-components/
