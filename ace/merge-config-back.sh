#!/bin/bash -x

NODE_NAME="$1"
SHARED_WORKPATH="$2"
OUTPUT_DIR="$3"

CONFIG_OUTPUT_DIR=${OUTPUT_DIR}/${NODE_NAME}
NODE_DIR=${SHARED_WORKPATH}/mqsi/components/${NODE_NAME}
SERVER_LIST="$(cat $CONFIG_OUTPUT_DIR/serverlist)"

sed -i '7,$d' ${NODE_DIR}/overrides/node.conf.yaml
cat $CONFIG_OUTPUT_DIR/node.conf.yaml >> ${NODE_DIR}/overrides/node.conf.yaml

for server in $SERVER_LIST; do
	SERVER_CONFIG_DIR=${CONFIG_OUTPUT_DIR}/${server}
	cp $SERVER_CONFIG_DIR/server.conf.yaml ${NODE_DIR}/servers/${server}/overrides/server.conf.yaml
done
