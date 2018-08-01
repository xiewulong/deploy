#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_PASSENGER=N
DEFAULT_PASSENGER_OVERWRITE=N
DEFAULT_PASSENGER_VERSION=5.3.3

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
  if [ -z $INSTALLATION_PATH ]; then
    INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
  fi
fi

RUBY=Y
source applications/ruby.sh

if [ -z $PASSENGER ]; then
  typeset -u PASSENGER
  read -p "$LANG_INSTALL_PASSENGER[Y/N]: ($DEFAULT_PASSENGER) " PASSENGER
  if [ -z $PASSENGER ]; then
    PASSENGER=$DEFAULT_PASSENGER
  fi
fi

PASSENGER_INSTALLATION_PATH="$INSTALLATION_PATH/passenger"
if [[ $PASSENGER == 'Y' && -d "$PASSENGER_INSTALLATION_PATH" ]]; then
  typeset -u PASSENGER
  read -p "$LANG_PASSENGER_OVERWRITE[Y/N]: ($DEFAULT_PASSENGER_OVERWRITE) " PASSENGER
  if [ -z $PASSENGER ]; then
    PASSENGER=$DEFAULT_PASSENGER_OVERWRITE
  fi
fi

if [ $PASSENGER == 'Y' ]; then
  if [ -z $PASSENGER_VERSION ]; then
    read -p "$LANG_PASSENGER_VERSION: ($DEFAULT_PASSENGER_VERSION) " PASSENGER_VERSION
    if [ -z $PASSENGER_VERSION ]; then
      PASSENGER_VERSION=$DEFAULT_PASSENGER_VERSION
    fi
  fi
fi

# Install
install_passenger() {
  if [ $PASSENGER != 'Y' ]; then
    return
  fi

  install_ruby

  set -x
  if [ -d "$PASSENGER_INSTALLATION_PATH" ]; then
    mv "$PASSENGER_INSTALLATION_PATH" "$PASSENGER_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [ ! -f "passenger-$PASSENGER_VERSION.tar.gz" ]; then
  #   curl --compressed -fLO "http://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz"
  # else
  if [ -f "passenger-$PASSENGER_VERSION.tar.gz" ]; then
    rm -rf "passenger-$PASSENGER_VERSION"
  fi
  wget -c "http://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz"
  tar zxvf "passenger-$PASSENGER_VERSION.tar.gz"
  mv "passenger-$PASSENGER_VERSION" "$PASSENGER_INSTALLATION_PATH"
  echo "export PATH=$PASSENGER_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/passenger.sh
  source /etc/profile.d/passenger.sh
  set +x
}
