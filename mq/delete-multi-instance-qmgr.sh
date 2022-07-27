#!/bin/bash

if [[ $USER != root ]]; then
	echo "Must be run as root!";
	exit 1;
fi

MQ_INST_PATH="/opt/mqm"

SHARED_FS="$1"
QM_NAME="$2"
MQ_USER="$3"
HOST2="$4"

SCRIPT_DIR="$(dirname $0)"
. $SCRIPT_DIR/../common/multi-instance-functions.sh


ON_HOST_BANNER="Running on \$HOSTNAME as \$USER"

echo Stopping QM active instance on current host...
QMGR_ACTIVE_STOP_CMD="
echo "$ON_HOST_BANNER"
endmqm -w $QM_NAME
dspmq -x -m $QM_NAME
"
run_on_current_host_mq "$QMGR_ACTIVE_STOP_CMD"
echo ----------------------------------------------------------
echo

echo Stopping QM standby instance on second host...
QMGR_STANDBY_START_CMD="
echo "$ON_HOST_BANNER"
endmqm -x $QM_NAME
dspmq -x -m $QM_NAME
"
run_on_host2_mq "$QMGR_STANDBY_START_CMD"
echo ----------------------------------------------------------
echo

echo Deleting QM on current host...
QMGR_DELETE_CMD="
echo $ON_HOST_BANNER
dltmqm $QM_NAME
dspmq
"
run_on_current_host_mq "$QMGR_DELETE_CMD"
echo ----------------------------------------------------------
echo

echo Removing QM on second host...
QMGR_REMOVE_CMD="
echo "$ON_HOST_BANNER"
rmvmqinf $QM_NAME
dspmq
"
run_on_host2_mq "$QMGR_REMOVE_CMD"
echo ----------------------------------------------------------
echo

echo ----------------------------------------------------------
# Delete QM directories on shared storage
echo Deleting QM directories on shared storage ...
QM_DIR=${SHARED_FS}/${QM_NAME}
rm -rf ${QM_DIR}
echo ----------------------------------------------------------
echo
