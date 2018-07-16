#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_PASSENGER=Y
DEFAULT_PASSENGER_VERSION=5.3.3

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi
PASSENGER_INSTALLATION_PATH="$INSTALLATION_PATH/passenger"

RUBY=Y
source applications/ruby.sh

if [ -z $PASSENGER ]; then
  typeset -u PASSENGER
  read -p "$LANG_INSTALL_PASSENGER[Y/N]: ($DEFAULT_PASSENGER) " PASSENGER
fi
if [ -z $PASSENGER ]; then
  PASSENGER=$DEFAULT_PASSENGER
fi
if [ $PASSENGER == 'Y' ]; then
  if [ -z $PASSENGER_VERSION ]; then
    read -p "$LANG_PASSENGER_VERSION: ($DEFAULT_PASSENGER_VERSION) " PASSENGER_VERSION
  fi
  if [ -z $PASSENGER_VERSION ]; then
    PASSENGER_VERSION=$DEFAULT_PASSENGER_VERSION
  fi
fi

# Install
install_passenger() {
  if [[ $PASSENGER != 'Y' || -d "$PASSENGER_INSTALLATION_PATH" ]]; then
    return
  fi

  install_ruby

  set -x
  curl --compressed -fLO "http://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz"
  tar zxvf "passenger-$PASSENGER_VERSION.tar.gz"
  mv "passenger-$PASSENGER_VERSION" "$PASSENGER_INSTALLATION_PATH"
  rm -rf "passenger-$PASSENGER_VERSION.tar.gz"
  echo "export PATH=$PASSENGER_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/passenger.sh
  source /etc/profile.d/passenger.sh
  set +x
}
