#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_PYTHON3=Y
DEFAULT_PYTHON3_OVERWRITE=N
DEFAULT_PYTHON3_VERSION=3.7.0

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
  if [ -z $INSTALLATION_PATH ]; then
    INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
  fi
fi

if [ -z $PYTHON3 ]; then
  typeset -u PYTHON3
  read -p "$LANG_INSTALL_PYTHON3[Y/N]: ($DEFAULT_PYTHON3) " PYTHON3
  if [ -z $PYTHON3 ]; then
    PYTHON3=$DEFAULT_PYTHON3
  fi
fi

PYTHON3_INSTALLATION_PATH="$INSTALLATION_PATH/python3"
if [[ $PYTHON3 == 'Y' && -d "$PYTHON3_INSTALLATION_PATH" ]]; then
  typeset -u PYTHON3
  read -p "$LANG_PYTHON3_OVERWRITE[Y/N]: ($DEFAULT_PYTHON3_OVERWRITE) " PYTHON3
  if [ -z $PYTHON3 ]; then
    PYTHON3=$DEFAULT_PYTHON3_OVERWRITE
  fi
fi

if [ $PYTHON3 == 'Y' ]; then
  if [ -z $PYTHON3_VERSION ]; then
    read -p "$LANG_PYTHON3_VERSION: ($DEFAULT_PYTHON3_VERSION) " PYTHON3_VERSION
    if [ -z $PYTHON3_VERSION ]; then
      PYTHON3_VERSION=$DEFAULT_PYTHON3_VERSION
    fi
  fi
fi

# Install
install_python3() {
  if [ $PYTHON3 != 'Y' ]; then
    return
  fi

  set -x
  if [ -d "$PYTHON3_INSTALLATION_PATH" ]; then
    mv "$PYTHON3_INSTALLATION_PATH" "$PYTHON3_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [ ! -f "Python-$PYTHON3_VERSION.tgz" ]; then
  #   curl --compressed -fLO "https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-$PYTHON3_VERSION.tgz"
  # else
  if [ -f "Python-$PYTHON3_VERSION.tgz" ]; then
    rm -rf "Python-$PYTHON3_VERSION"
  fi
  wget -c "https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-$PYTHON3_VERSION.tgz"
  tar zxvf "Python-$PYTHON3_VERSION.tgz"
  cd "Python-$PYTHON3_VERSION"
  ./configure --prefix="$PYTHON3_INSTALLATION_PATH"
  make
  make install
  cd ..
  echo "export PATH=$PYTHON3_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/python3.sh
  source /etc/profile.d/python3.sh
  set +x
}
