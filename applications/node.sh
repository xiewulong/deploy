#!/bin/bash

set -e

# Options
NODE_INSTALLATION_PATH="$INSTALLATION_PATH/node"

if [ -z $NODE ]; then
  typeset -u NODE
  if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
    read -p "$LANG_INSTALL_NODE[Y/N]: ($DEFAULT_NODE) " NODE
  fi
  if [ -z $NODE ]; then
    NODE=$DEFAULT_NODE
  fi
fi

if [[ $NODE == 'Y' && -d "$NODE_INSTALLATION_PATH" ]]; then
  typeset -u NODE
  if [ -z $NODE_OVERWRITE ]; then
    if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
      read -p "$LANG_NODE_OVERWRITE[Y/N]: ($DEFAULT_NODE_OVERWRITE) " NODE
    fi
    if [ -z $NODE ]; then
      NODE=$DEFAULT_NODE_OVERWRITE
    fi
  else
    NODE=$NODE_OVERWRITE
  fi
fi

if [ $NODE == 'Y' ]; then
  if [ -z $NODE_VERSION ]; then
    if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
      read -p "$LANG_NODE_VERSION: ($DEFAULT_NODE_VERSION) " NODE_VERSION
    fi
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
  # npm config set disturl https://npm.taobao.org/dist --global
  # npm config set registry https://registry.npm.taobao.org --global
  # npm install -g --registry=https://registry.npm.taobao.org npm@latest yarn
  # yarn config set disturl https://npm.taobao.org/dist --global
  # yarn config set registry https://registry.npm.taobao.org --global
  set +x
}
