#!/bin/bash

#
# Load configuration
#

CONFIG_NAME=$1
if [ -z "$CONFIG_NAME" ]; then
  echo "Please specify configuration name as parameter"
  echo "  $0 [config name]"
  exit 1
fi

CONFIG_FILENAME="scripts/configs/$CONFIG_NAME.inc.sh"
echo "Using config file '$CONFIG_FILENAME'"
if [ ! -e "$CONFIG_FILENAME" ]; then
  echo "Configuration file '$CONFIG_FILENAME' not found"
  exit 1
fi


if [ -e "config.inc.sh" ]; then
  echo
  echo "ERROR: Are you executing the scripts from the scripts directory? You should call the scripts from '../'"
  echo
  exit 1
fi


echo "Loading config header"
. ./scripts/config_header.inc.sh

echo "Loading config $CONFIG_FILENAME"
. "$CONFIG_FILENAME"

echo "Loading config footer"
. ./scripts/config_footer.inc.sh

