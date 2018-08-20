#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_NODE=N
DEFAULT_NODE_OVERWRITE=N
DEFAULT_NODE_VERSION=8.11.4

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
  if [ -z $INSTALLATION_PATH ]; then
    INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
  fi
fi

NODE_INSTALLATION_PATH="$INSTALLATION_PATH/node"

if [ -z $NODE ]; then
  typeset -u NODE
  read -p "$LANG_INSTALL_NODE[Y/N]: ($DEFAULT_NODE) " NODE
  if [ -z $NODE ]; then
    NODE=$DEFAULT_NODE
  fi
fi

NODE_INSTALLATION_PATH="$INSTALLATION_PATH/node"
if [[ $NODE == 'Y' && -d "$NODE_INSTALLATION_PATH" ]]; then
  typeset -u NODE
  read -p "$LANG_NODE_OVERWRITE[Y/N]: ($DEFAULT_NODE_OVERWRITE) " NODE
  if [ -z $NODE ]; then
    NODE=$DEFAULT_NODE_OVERWRITE
  fi
fi

if [ $NODE == 'Y' ]; then
  if [ -z $NODE_VERSION ]; then
    read -p "$LANG_NODE_VERSION: ($DEFAULT_NODE_VERSION) " NODE_VERSION
    if [ -z $NODE_VERSION ]; then
      NODE_VERSION=$DEFAULT_NODE_VERSION
    fi
  fi
fi

# Install
install_node() {
  if [ $NODE != 'Y' ]; then
    return
  fi

  set -x
  if [ -d "$NODE_INSTALLATION_PATH" ]; then
    mv "$NODE_INSTALLATION_PATH" "$NODE_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [ ! -f "node-v$NODE_VERSION-linux-x64.tar.xz" ]; then
  #   curl --compressed -fLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
  # else
  if [ -f "node-v$NODE_VERSION-linux-x64.tar.xz" ]; then
    rm -rf "node-v$NODE_VERSION-linux-x64"
  fi
  wget -c "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
  tar xvf "node-v$NODE_VERSION-linux-x64.tar.xz"
  chown root:root -R "node-v$NODE_VERSION-linux-x64"
  mv "node-v$NODE_VERSION-linux-x64" "$NODE_INSTALLATION_PATH"
  echo "export PATH=$NODE_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/node.sh
  source /etc/profile.d/node.sh
  # npm install -g --registry=https://registry.npm.taobao.org cnpm npm@latest yarn
  set +x
}
