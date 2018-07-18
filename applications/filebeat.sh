#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_FILEBEAT=Y
DEFAULT_FILEBEAT_VERSION=6.3.1

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi
FILEBEAT_INSTALLATION_PATH="$INSTALLATION_PATH/filebeat"

if [ -z $FILEBEAT ]; then
  typeset -u FILEBEAT
  read -p "$LANG_INSTALL_FILEBEAT[Y/N]: ($DEFAULT_FILEBEAT) " FILEBEAT
fi
if [ -z $FILEBEAT ]; then
  FILEBEAT=$DEFAULT_FILEBEAT
fi
if [ $FILEBEAT == 'Y' ]; then
  if [ -z $FILEBEAT_VERSION ]; then
    read -p "$LANG_FILEBEAT_VERSION: ($DEFAULT_FILEBEAT_VERSION) " FILEBEAT_VERSION
  fi
  if [ -z $FILEBEAT_VERSION ]; then
    FILEBEAT_VERSION=$DEFAULT_FILEBEAT_VERSION
  fi
fi

# Install
install_filebeat() {
  if [[ $FILEBEAT != 'Y' || -d "$FILEBEAT_INSTALLATION_PATH" ]]; then
    return
  fi

  FILEBEAT_FOLDER="filebeat-$FILEBEAT_VERSION-linux-`uname -m`"

  set -x
  curl --compressed -fLO "https://artifacts.elastic.co/downloads/beats/filebeat/$FILEBEAT_FOLDER.tar.gz"
  tar xvf "$FILEBEAT_FOLDER.tar.gz"
  mv "$FILEBEAT_FOLDER" "$FILEBEAT_INSTALLATION_PATH"
  # rm -rf "$FILEBEAT_FOLDER.tar.gz"
  ln -sf "$FILEBEAT_INSTALLATION_PATH/filebeat" /usr/local/bin/filebeat
  set +x
}
