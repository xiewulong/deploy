#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_NODE=Y
DEFAULT_NODE_VERSION=8.11.2

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi
NODE_INSTALLATION_PATH="$INSTALLATION_PATH/node"

if [ -z $NODE ]; then
  typeset -u NODE
  read -p "$LANG_INSTALL_NODE[Y/N]: ($DEFAULT_NODE) " NODE
fi
if [ -z $NODE ]; then
  NODE=$DEFAULT_NODE
fi
if [ $NODE == 'Y' ]; then
  if [ -z $NODE_VERSION ]; then
    read -p "$LANG_NODE_VERSION: ($DEFAULT_NODE_VERSION) " NODE_VERSION
  fi
  if [ -z $NODE_VERSION ]; then
    NODE_VERSION=$DEFAULT_NODE_VERSION
  fi
fi

# Install
install_node() {
  if [[ $NODE != 'Y' || -d "$NODE_INSTALLATION_PATH" ]]; then
    return
  fi

  set -x
  curl --compressed -fLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
  tar xvf "node-v$NODE_VERSION-linux-x64.tar.xz"
  mv "node-v$NODE_VERSION-linux-x64" "$NODE_INSTALLATION_PATH"
  rm -rf "node-v$NODE_VERSION-linux-x64.tar.xz"
  echo "export PATH=$NODE_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/node.sh
  source /etc/profile.d/node.sh
  set +x
}
