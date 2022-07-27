#!/bin/bash -x

NODE_NAME="$1"
SERVER_LIST="$2"
SHARED_WORKPATH="$3"
OUTPUT_DIR="$4"

CONFIG_OUTPUT_DIR=${OUTPUT_DIR}/${NODE_NAME}
NODE_DIR=${SHARED_WORKPATH}/mqsi/components/${NODE_NAME}

# cp $CONFIG_OUTPUT_DIR ${NODE_DIR}/overrides/node.conf.yaml

for server in $SERVER_LIST; do
	SERVER_CONFIG_DIR=${CONFIG_OUTPUT_DIR}/${server}
	cp $SERVER_CONFIG_DIR ${NODE_DIR}/servers/${server}/overrides/server.conf.yaml
done
