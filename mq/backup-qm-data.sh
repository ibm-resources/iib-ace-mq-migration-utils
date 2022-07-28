#!/bin/bash

QM="$1"
CONF_OUTPUT_DIR=output

echo "Extracting data..."

eval "$(dspmqinf -o stanza $QM | grep DataPath)"
eval "$(grep LogPath $DataPath/qm.ini)"
echo Detected DataPath: $DataPath
echo Detected LogPath: $LogPath

VERSION=$(dspmqver -f 2 | grep -oP '\d\.\d\.\d\.\d')
tar -zcf "${QM}.${VERSION}.tar.gz" ./$CONF_OUTPUT_DIR/ "$DataPath" "$LogPath"

echo "Data extraction completed!"
echo "Configuration and data have been archived."
