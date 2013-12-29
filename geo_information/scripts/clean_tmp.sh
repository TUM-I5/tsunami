#! /bin/bash

NO_PARAM_CHECK=true
. ./scripts/config_header.inc.sh

TMP_FILES="bath.nc bath2.nc bath3.nc displ.nc displ2.nc displ3.nc tempDispl.xyz"


echo "********************************"
echo "* Cleaning up temporary files  *"
echo "********************************"

for i in $TMP_FILES; do
  echo "Removing $TEMPDIR/$i"
  rm -f "$TEMPDIR/$i"
done

