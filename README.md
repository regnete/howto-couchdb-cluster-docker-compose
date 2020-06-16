# How to setup a CouchDB cluster with docker-compose

## Setup
1. clone this repo

2. adjust values in .env to your needs

3. `docker-compose up -d`

4. `./init-cluster.sh`


## Notes

- Explicitly set an erlang cookie on each node via ENV var. Cookie value must be equal on all nodes. 
Otherwise you will get connection issues between nodes (e.g. "Connection attempt from disallowed node")

- Mount the `/opt/couchdb/etc/local.d` directory as volume to have it persisted over `docker-compose down` and `docker-compose up -d`. 
Otherwise each node will write new given COUCHDB_PASSWORD's hash on every `docker-compose up -d` to `/opt/couchdb/etc/local.d/docker.ini`.
In consequence the hashes for the admin passwords differ between nodes and you are ending up with connection issues between the nodes (e.g. `'no_majority'`).


## Inspired by 
- https://docs.couchdb.org/en/master/setup/cluster.html
- https://github.com/apache/couchdb-docker/issues/74
- https://github.com/apache/couchdb/issues/2858

