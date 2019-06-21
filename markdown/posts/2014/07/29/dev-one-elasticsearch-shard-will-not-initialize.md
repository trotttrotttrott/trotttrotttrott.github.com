## one elasticsearch shard will not initialize

Working with Elasticsearch, you end up obsessing over [cluster health](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cluster-health.html). A cluster is either red, yellow, or green. Apparently yellow is okay, but it means that replica shards are missing. Elasticsearch should automatically take care of this dilemma for you to get a cluster status to green. In my experience, it usually does. Today it did not. A cluster I'm maintaining was yellow all day and I wasted a lot of time scouring logs.

`> curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'`

```json
{
  "cluster_name" : "whatever-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 12,
  "number_of_data_nodes" : 12,
  "active_primary_shards" : 30,
  "active_shards" : 89,
  "relocating_shards" : 0,
  "initializing_shards" : 1,
  "unassigned_shards" : 0
}
```

If this happens to you, do not scour the logs. Use [cat recovery](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/cat-recovery.html).

`> curl -XGET 'localhost:9200/_cat/recovery?v'`

Look for a row that looks like this:

`172.31.9.96 datapoints 2 41390776 replica init n/a some-host n/a n/a 0 0.0% 0 0.0%`

In my case, this shard was attempting to initialize with "n/a" for source\_host.

Restart Elasticsearch on the target\_host ("some-host" in the example) and Elasticsearch should be able to take care of the rest.
