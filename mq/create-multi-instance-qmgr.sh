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


echo ----------------------------------------------------------
# Create QM directories on shared storage
echo Creating QM directories on shared storage ...
QM_DIR=${SHARED_FS}/${QM_NAME}
mkdir -p ${QM_DIR}/{logs,qmgrs}
chown -R $MQ_USER:mqm $QM_DIR
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
