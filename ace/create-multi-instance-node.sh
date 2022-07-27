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
. $SCRIPT_DIR/multi-instance-functions.sh


echo ----------------------------------------------------------
# Create QM directories on shared storage
echo Creating QM directories on shared storage ...
QM_DIR=${SHARED_FS}/${QM_NAME}
mkdir -p ${QM_DIR}/{logs,qmgrs}
chown -R $MQ_USER:mqm $QM_DIR
echo ----------------------------------------------------------
echo
# Create integration node directory on shared storage
echo Creating integration node directory on shared storeage ...
NODE_DIR=${SHARED_FS}/${NODE_NAME}
mkdir -p $NODE_DIR
chown -R $ACE_USER:mqbrkrs $NODE_DIR
echo ----------------------------------------------------------
echo


ON_HOST_BANNER="Running on \$HOSTNAME as \$USER"

echo Creating QM on current host...
QMGR_CREATE_CMD="
echo $ON_HOST_BANNER
crtmqm -ld ${QM_DIR}/logs -md ${QM_DIR}/qmgrs $QM_NAME
dspmqinf -o command $QM_NAME > /tmp/${QM_NAME}.host2-command
"
run_on_current_host_mq "$QMGR_CREATE_CMD"
echo ----------------------------------------------------------
echo

echo Adding QM on second host...
QMGR_ADD_CMD="
echo $ON_HOST_BANNER
$(cat /tmp/${QM_NAME}.host2-command)
"
run_on_host2_mq "$QMGR_ADD_CMD"
echo ----------------------------------------------------------
echo

echo Starting QM active instance on current host...
QMGR_ACTIVE_START_CMD="
echo $ON_HOST_BANNER
strmqm -x $QM_NAME
dspmq -x -m $QM_NAME
"
run_on_current_host_mq "$QMGR_ACTIVE_START_CMD"
echo ----------------------------------------------------------
echo

echo Starting QM standby instance on second host...
QMGR_STANDBY_START_CMD="
echo $ON_HOST_BANNER
strmqm -x $QM_NAME
dspmq -x -m $QM_NAME
"
run_on_host2_mq "$QMGR_STANDBY_START_CMD"
echo ----------------------------------------------------------
echo

echo Creating integration node on current host...
ACE_NODE_CREATE_CMD="
echo $ON_HOST_BANNER
mqsicreatebroker $NODE_NAME -q $QM_NAME -e $NODE_DIR
mqsilist $NODE_NAME
"
run_on_current_host_ace "$ACE_NODE_CREATE_CMD"
echo ----------------------------------------------------------
echo

echo Adding integration node intance on second host...
ACE_NODE_ADD_CMD="
echo $ON_HOST_BANNER
mqsiaddbrokerinstance $NODE_NAME -e $NODE_DIR
mqsilist $NODE_NAME
"
run_on_host2_ace "$ACE_NODE_ADD_CMD"
echo ----------------------------------------------------------
echo

echo Starting integration node active instance on current host...
ACE_NODE_ACTIVE_START_CMD="
echo $ON_HOST_BANNER
mqsistart $NODE_NAME
mqsilist $NODE_NAME
"
run_on_current_host_ace "$ACE_NODE_ACTIVE_START_CMD"
echo ----------------------------------------------------------
echo

echo Starting integration node standby instance on second host...
ACE_NODE_STANDBY_START_CMD="
echo $ON_HOST_BANNER
mqsistart $NODE_NAME
mqsilist $NODENAME
"
run_on_host2_ace "$ACE_NODE_STANDBY_START_CMD"
echo ----------------------------------------------------------
echo
