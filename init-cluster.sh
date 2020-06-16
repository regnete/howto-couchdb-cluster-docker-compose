#!/bin/bash

source .env

IFS=","
COORDINATOR_NODE="0"
ADDITIONAL_NODES="1,2"
ALL_NODES="${COORDINATOR_NODE},${ADDITIONAL_NODES}"

# see https://docs.couchdb.org/en/master/setup/cluster.html

for NODE_ID in $COORDINATOR_NODE
do
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}${NODE_ID}/_cluster_setup" \
  -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_USER}"'", "node_count":"3"}'
  echo You may safely ignore the warning above.
done

for NODE_ID in $ADDITIONAL_NODES
do
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_PASSWORD}"'", "port": 5984, "node_count": "3", "remote_node": "'"couchdb-${NODE_ID}.${DEPLOYMENT_NAME}"'", "remote_current_user": "'"${COUCHDB_USER}"'", "remote_current_password": "'"${COUCHDB_PASSWORD}"'" }'
  curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "add_node", "host":"'"couchdb-${NODE_ID}.${DEPLOYMENT_NAME}"'", "port": 5984, "username": "'"${COUCHDB_USER}"'", "password":"'"${COUCHDB_PASSWORD}"'"}'
done

# see https://github.com/apache/couchdb/issues/2858
curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/"

curl -X POST -H "Content-Type: application/json" "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup" -d '{"action": "finish_cluster"}'


curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_cluster_setup"

curl "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@127.0.0.1:${PORT_BASE}0/_membership"


echo Your cluster nodes are available at:
for NODE_ID in ${ALL_NODES}
do
  echo    http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:${PORT_BASE}${NODE_ID}
done
