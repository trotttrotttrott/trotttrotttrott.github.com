## [Carousul](https://github.com/trotttrotttrott/carousul)

> **C**assandra **A**nti-entropy **R**epair **ou** Con**sul**

A few definitions for context...

###### [Cassandra](http://cassandra.apache.org/)

A masterless, multi-node, multi-region database that boasts linear scalability, high availability, and fault tolerance.

###### [Entropy](https://en.wikipedia.org/wiki/Entropy_(disambiguation))

In the case of databases, the tendency to become increasingly disordered. Frequent data deletions and downed nodes are common causes.

###### Anti-entropy Repair

The act of reconciling disorder within a database system. It's performed to ensure data consistency across replicas.

### Problem

Cassandra does not perform anti-entropy repair automatically. However, the [nodetool utility](https://docs.datastax.com/en/archived/cassandra/3.0/cassandra/tools/toolsNodetool.html) provides the [`nodetool repair`](https://docs.datastax.com/en/archived/cassandra/3.0/cassandra/tools/toolsRepair.html) command for performing it. It's [documented](https://docs.datastax.com/en/archived/cassandra/3.0/cassandra/operations/opsRepairNodesTOC.html) that operators should "...use nodetool repair as part of your regular maintenance routine...". But who even has a regular maintenance routine in 2019? It seems to me a more honest recommendation would be to automate this as well as you can because it's too complicated for a masterless, distributed database cluster to coordinate automatically out of the box.

I've observed that there's a fair amount of confusion regarding which nodes must run `nodetool repair` to fully repair a cluster. Though some are dated, the following threads demonstrate this...

* [https://stackoverflow.com/questions/37921042/cassandra-nodetool-repair-best-practices](https://stackoverflow.com/questions/37921042/cassandra-nodetool-repair-best-practices)
* [https://dba.stackexchange.com/questions/82414/do-you-have-to-run-nodetool-repair-on-every-node](https://dba.stackexchange.com/questions/82414/do-you-have-to-run-nodetool-repair-on-every-node)
* [https://stackoverflow.com/questions/54006795/cassandra-sequential-repair-does-not-repair-all-nodes-on-one-run](https://stackoverflow.com/questions/54006795/cassandra-sequential-repair-does-not-repair-all-nodes-on-one-run)

The accepted answer from the first link states that you only need to run the repair operation on one node in a cluster and you're done. The accepted answer of the second states that you need to run repair on every node in the cluster. The third answer aligns with the second - every single node.

Depending on replication factors and node counts, each answer may be true. For example, if each datacenter has 3 nodes and your replication factor is 3, then running repair on a single node may be adequate for completing the job. However, if each datacenter has 5 nodes and your replication factor is 3, then you are only guaranteed to have repaired 3/5 of all data.

In the latter case, you must run repair on all nodes at least within a single datacenter to repair all data. I say, "at least", because more repairs may be required if replication factors are not consistent among datacenters. On top of that, only one node can be repaired at a time.

One more definition...

###### [**Consul**](https://www.consul.io/)

A distributed service mesh. It can also be described as a key/value store, event system, and DNS resolver. In addition to all of that, it provides a [session mechanism](https://www.consul.io/docs/internals/sessions.html) that can be used for building distributed locks.

### Solution

Automate the repair of all nodes within a single datacenter, one at a time. "Carousul" is what I came up with - [https://github.com/trotttrotttrott/carousul](https://github.com/trotttrotttrott/carousul).

It's a Go program that performs datacenter parallel repairs while using Consul for distributed locking to ensure that only the node that holds the lock can perform a repair. Repairs are performed one by one until each has had a turn obtaining the lock and completing the repair operation.

In addition, it outputs metrics to file for a Prometheus [node exporter textfile collector](https://github.com/prometheus/node_exporter#textfile-collector) to consume.

Carousul's limitation is that it can only run in a single datacenter at a time because Consul cannot hold sessions across datacenters. This is fine if you only need to run repair in a single datacenter to complete the job. If not, this is not a complete solution - further synchronization must occur.
