#!/bin/bash

if [[ $USER != root ]]; then
	echo "Must be run as root!";
	exit 1;
fi

MQ_INST_PATH="/opt/mqm"
ACE_INST_PATH="/opt/ace-12.0.3.0"

SHARED_FS="$1"
NODE_NAME="$2"
ACE_USER="$3"
QM_NAME="$4"
MQ_USER="$5"
HOST2="$6"

SCRIPT_DIR="$(dirname $0)"
. $SCRIPT_DIR/../common/multi-instance-functions.sh


ON_HOST_BANNER="Running on \$HOSTNAME as \$USER"

echo Stopping integration node active instance on current host...
ACE_NODE_ACTIVE_STOP_CMD="
echo "$ON_HOST_BANNER"
mqsistop $NODE_NAME
mqsilist $NODE_NAME
"
run_on_current_host_ace "$ACE_NODE_ACTIVE_STOP_CMD"
echo ----------------------------------------------------------
echo

echo Stopping integration node standby instance on second host...
ACE_NODE_STANDBY_STOP_CMD="
echo "$ON_HOST_BANNER"
mqsistop $NODE_NAME
mqsilist $NODENAME
"
run_on_host2_ace "$ACE_NODE_STANDBY_STOP_CMD"
echo ----------------------------------------------------------
echo

echo Removing integration node intance from second host...
ACE_NODE_REMOVE_CMD="
echo "$ON_HOST_BANNER"
mqsiremovebrokerinstance $NODE_NAME 
"
run_on_host2_ace "$ACE_NODE_REMOVE_CMD"
echo ----------------------------------------------------------
echo

echo Deleting integration node from current host...
ACE_NODE_DELETE_CMD="
echo "$ON_HOST_BANNER"
mqsideletebroker $NODE_NAME -w
"
run_on_current_host_ace "$ACE_NODE_DELETE_CMD"
echo ----------------------------------------------------------
echo

# Delete integration node directory on shared storage
echo Deleting integration node directory on shared storeage...
NODE_DIR=${SHARED_FS}/${NODE_NAME}
rm -rf $NODE_DIR
echo ----------------------------------------------------------
echo

# Deleting the multi instance queue manager
. $SCRIPT_DIR/../mq/delete-multi-instance-qmgr.sh "$SHARED_FS" "$QM_NAME" "$MQ_USER" "$HOST2"
