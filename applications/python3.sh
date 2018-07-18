#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_PYTHON3=Y
DEFAULT_PYTHON3_VERSION=3.7.0

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi
PYTHON3_INSTALLATION_PATH="$INSTALLATION_PATH/python3"

if [ -z $PYTHON3 ]; then
  typeset -u PYTHON3
  read -p "$LANG_INSTALL_PYTHON3[Y/N]: ($DEFAULT_PYTHON3) " PYTHON3
fi
if [ -z $PYTHON3 ]; then
  PYTHON3=$DEFAULT_PYTHON3
fi
if [ $PYTHON3 == 'Y' ]; then
  if [ -z $PYTHON3_VERSION ]; then
    read -p "$LANG_PYTHON3_VERSION: ($DEFAULT_PYTHON3_VERSION) " PYTHON3_VERSION
  fi
  if [ -z $PYTHON3_VERSION ]; then
    PYTHON3_VERSION=$DEFAULT_PYTHON3_VERSION
  fi
fi

# Install
install_python3() {
  if [[ $PYTHON3 != 'Y' || -d "$PYTHON3_INSTALLATION_PATH" ]]; then
    return
  fi

  set -x
  curl --compressed -fLO "https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-$PYTHON3_VERSION.tgz"
  tar zxvf "Python-$PYTHON3_VERSION.tgz"
  cd "Python-$PYTHON3_VERSION"
  ./configure --prefix="$PYTHON3_INSTALLATION_PATH"
  make && make install
  cd ..
  # rm -rf "Python-$PYTHON3_VERSION" "Python-$PYTHON3_VERSION.tgz"
  echo "export PATH=$PYTHON3_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/python3.sh
  source /etc/profile.d/python3.sh
  set +x
}
