#!/bin/bash

QM="$1"
CONF_OUTPUT_DIR=output/${QM}
DMPMQCFG_DIR=${CONF_OUTPUT_DIR}/dmpmqcfg
mkdir -p $DMPMQCFG_DIR/all
mkdir -p $CONF_OUTPUT_DIR/dspmqspl
mkdir -p $CONF_OUTPUT_DIR/stanza

echo "Extracting configuration..."

_x_OPTS="all object authrec chlauth sub policy"
_t_OPTS="all authinfo channel comminfo listener namelist process queue qmgr service topic"
_o_OPTS="mqsc 1line 2line setmqauth grtmqaut setmqspl"

for _x_opt in $_x_OPTS; do
        for _t_opt in $_t_OPTS; do
                for _o_opt in $_o_OPTS; do
                        dmpmqcfg_cmd="dmpmqcfg -x $_x_opt -t $_t_opt -o $_o_opt -m $QM"
                        dmpmqcfg_all_cmd="dmpmqcfg -x $_x_opt -a -t $_t_opt -o $_o_opt -m $QM"
                        eval "$dmpmqcfg_cmd" > /dev/null 2>&1  && eval "$dmpmqcfg_cmd" > $DMPMQCFG_DIR/all/${QM}.dmpmqcfg.${_t_opt}.${_x_opt}.${_o_opt} && \
                                eval "$dmpmqcfg_all_cmd" > $DMPMQCFG_DIR/all/${QM}.all.dmpmqcfg.${_t_opt}.${_x_opt}.${_o_opt}
                done
        done
done

dmpmqcfg -m ${QM} -a > $DMPMQCFG_DIR/${QM}.dmpmqcfg.all.mqsc
dmpmqcfg -m ${QM} -a -o 1line > $DMPMQCFG_DIR/${QM}.dmpmqcfg.all.1line.mqsc
dmpmqcfg -m ${QM} -o setmqaut > $DMPMQCFG_DIR/${QM}.setmqaut.sh

dspmqspl -m $QM -export > $CONF_OUTPUT_DIR/dspmqspl/${QM}.dmpmqspl

dspmqinf -o stanza $QM > $CONF_OUTPUT_DIR/stanza/dspmqinf.ini
dspmqinf -o 'command' $QM > $CONF_OUTPUT_DIR/stanza/dspmqinf.sh

echo "Configuration extraction complete!"

