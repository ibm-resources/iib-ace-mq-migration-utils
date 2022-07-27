#!/bin/bash

run_on_current_host () {
	USR="$1"
	CMD="$2"
	su -s /bin/bash -c "$CMD" - "$USR"
}

run_on_host2 () {
	USR="$1"
	CMD="$2"
	ssh root@$HOST2 "su -s /bin/bash -c '$CMD' - $USR"
}

run_on_current_host_ace () {
	CMD="
	. ${ACE_INST_PATH}/server/bin/mqsiprofile
	$1
	"
	run_on_current_host "$ACE_USER" "$CMD"
}

run_on_current_host_mq () {
	CMD="
	. ${MQ_INST_PATH}/bin/setmqenv -s
	$1
	"
	run_on_current_host "$MQ_USER" "$CMD"
}

run_on_host2_ace() {
	CMD="
	. ${ACE_INST_PATH}/server/bin/mqsiprofile
	$1
	"
	run_on_host2 "$ACE_USER" "$CMD"
}

run_on_host2_mq() {
	CMD="
	. ${MQ_INST_PATH}/bin/setmqenv -s
	$1
	"
	run_on_host2 "$MQ_USER" "$CMD"
}

