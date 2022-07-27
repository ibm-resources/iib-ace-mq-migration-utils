#!/bin/bash -x

NODE_NAME="$1"
SHARED_WORKPATH="$2"
OUTPUT_DIR="$3"


CONFIG_OUTPUT_DIR=${OUTPUT_DIR}/${NODE_NAME}
NODE_DIR=${SHARED_WORKPATH}/mqsi/components/${NODE_NAME}
SERVER_LIST="$(for component in ${NODE_DIR}/servers/*; do basename $component; done)"

mkdir -p ${CONFIG_OUTPUT_DIR}
sed -e '/brokerDefaultCCSID/d' -e '/brokerUUID/d' ${NODE_DIR}/overrides/node.conf.yaml > $CONFIG_OUTPUT_DIR/node.conf.yaml

for server in $SERVER_LIST; do
	SERVER_CONFIG_DIR=${CONFIG_OUTPUT_DIR}/${server}
	mkdir -p $SERVER_CONFIG_DIR
	cp ${NODE_DIR}/servers/${server}/overrides/server.conf.yaml $SERVER_CONFIG_DIR
done

echo $SERVER_LIST > $CONFIG_OUTPUT_DIR/serverlist
