#!/bin/bash
set -e

# Options
if [[ -z $DOCKER_COMPOSE ]]; then
  typeset -u DOCKER_COMPOSE
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_DOCKER_COMPOSE[Y/N]: ($DEFAULT_DOCKER_COMPOSE) " DOCKER_COMPOSE
  fi
  if [[ -z $DOCKER_COMPOSE ]]; then
    DOCKER_COMPOSE=$DEFAULT_DOCKER_COMPOSE
  fi
fi

if [[ $DOCKER_COMPOSE == 'Y' ]]; then
  if [[ -z $DOCKER_COMPOSE_VERSION ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_DOCKER_COMPOSE_VERSION: ($DEFAULT_DOCKER_COMPOSE_VERSION) " DOCKER_COMPOSE_VERSION
    fi
    if [[ -z $DOCKER_COMPOSE_VERSION ]]; then
      DOCKER_COMPOSE_VERSION=$DEFAULT_DOCKER_COMPOSE_VERSION
    fi
  fi
fi

# Install
install_docker_compose() {
  if [[ $DOCKER_COMPOSE != 'Y' ]]; then
    return
  fi

  set -x
  curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  set +x
}
