#!/bin/bash -x

NODE_NAME="$1"
SERVER_LIST=`./list-of-servers.sh $NODE_NAME`

for server in $SERVER_LIST; do
	echo $server
	mqsideploy $NODE_NAME -e $server -a misc-files/empty.bar --clear
done
