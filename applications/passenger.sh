#!/bin/bash

set -e

# Options
RUBY=Y
source "$CSD/applications/ruby.sh"

PASSENGER_INSTALLATION_PATH="$INSTALLATION_PATH/passenger"

if [[ -z $PASSENGER ]]; then
  typeset -u PASSENGER
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_PASSENGER[Y/N]: ($DEFAULT_PASSENGER) " PASSENGER
  fi
  if [[ -z $PASSENGER ]]; then
    PASSENGER=$DEFAULT_PASSENGER
  fi
fi

if [[ $PASSENGER == 'Y' && -d "$PASSENGER_INSTALLATION_PATH" ]]; then
  typeset -u PASSENGER
  if [[ -z $PASSENGER_OVERWRITE ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_PASSENGER_OVERWRITE[Y/N]: ($DEFAULT_PASSENGER_OVERWRITE) " PASSENGER
    fi
    if [[ -z $PASSENGER ]]; then
      PASSENGER=$DEFAULT_PASSENGER_OVERWRITE
    fi
  else
    PASSENGER=$PASSENGER_OVERWRITE
  fi
fi

if [[ $PASSENGER == 'Y' ]]; then
  if [[ -z $PASSENGER_VERSION ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_PASSENGER_VERSION: ($DEFAULT_PASSENGER_VERSION) " PASSENGER_VERSION
    fi
    if [[ -z $PASSENGER_VERSION ]]; then
      PASSENGER_VERSION=$DEFAULT_PASSENGER_VERSION
    fi
  fi
fi

# Install
install_passenger() {
  if [[ $PASSENGER != 'Y' ]]; then
    return
  fi

  install_ruby

  set -x
  if [[ -d "$PASSENGER_INSTALLATION_PATH" ]]; then
    mv "$PASSENGER_INSTALLATION_PATH" "$PASSENGER_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [[ ! -f "passenger-$PASSENGER_VERSION.tar.gz" ]]; then
  #   curl --compressed -fLO "http://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz"
  # else
  if [[ -f "passenger-$PASSENGER_VERSION.tar.gz" ]]; then
    rm -rf "passenger-$PASSENGER_VERSION"
  fi
  wget -c "http://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz"
  tar zxvf "passenger-$PASSENGER_VERSION.tar.gz"
  mv "passenger-$PASSENGER_VERSION" "$PASSENGER_INSTALLATION_PATH"
  echo "export PATH=$PASSENGER_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/passenger.sh
  source /etc/profile.d/passenger.sh
  set +x
}
