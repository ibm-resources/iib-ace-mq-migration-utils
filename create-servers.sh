#!/bin/bash -x
NODE_NAME="$1"
SERVER_LIST="$2"

for server in $SERVER_LIST; do
        echo $server
        mqsicreateexecutiongroup $NODE_NAME -e $server
done
