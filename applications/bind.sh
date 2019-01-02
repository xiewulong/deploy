#!/bin/bash

set -e

# Options
if [ -z $BIND ]; then
  typeset -u BIND
  read -p "$LANG_INSTALL_BIND[Y/N]: ($DEFAULT_BIND) " BIND
  if [ -z $BIND ]; then
    BIND=$DEFAULT_BIND
  fi
fi

BIND_INSTALLATION_PATH="$INSTALLATION_PATH/bind"
if [[ $BIND == 'Y' && -d "$BIND_INSTALLATION_PATH" ]]; then
  typeset -u BIND
  read -p "$LANG_BIND_OVERWRITE[Y/N]: ($DEFAULT_BIND_OVERWRITE) " BIND
  if [ -z $BIND ]; then
    BIND=$DEFAULT_BIND_OVERWRITE
  fi
fi

if [ $BIND == 'Y' ]; then
  if [ -z $BIND_VERSION ]; then
    read -p "$LANG_BIND_VERSION: ($DEFAULT_BIND_VERSION) " BIND_VERSION
    if [ -z $BIND_VERSION ]; then
      BIND_VERSION=$DEFAULT_BIND_VERSION
    fi
  fi
fi

# Install
install_bind() {
  if [ $BIND != 'Y' ]; then
    return
  fi

  set -x
  if [ -d "$BIND_INSTALLATION_PATH" ]; then
    mv "$BIND_INSTALLATION_PATH" "$BIND_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  if [ -f "bind-$BIND_VERSION.tar.gz" ]; then
    rm -rf "bind-$BIND_VERSION"
  fi
  typeset -l BIND_VERSION_FOR_URL
  BIND_VERSION_FOR_URL=${BIND_VERSION//./-}
  wget -c "https://www.isc.org/downloads/file/bind-$BIND_VERSION_FOR_URL?version=tar-gz" -O "bind-$BIND_VERSION.tar.gz"
  tar xvf "bind-$BIND_VERSION.tar.gz"
  chown root:root -R "bind-$BIND_VERSION"
  cd "bind-$BIND_VERSION"
  ./configure --prefix="$BIND_INSTALLATION_PATH"
  make
  make install
  cd ..
  echo "export PATH=$BIND_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/bind.sh
  echo "export PATH=$BIND_INSTALLATION_PATH/sbin:"'$PATH' >> /etc/profile.d/bind.sh
  source /etc/profile.d/bind.sh
  set +x
}
