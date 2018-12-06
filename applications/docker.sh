#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_DOCKER=N
DEFAULT_DOCKER_COMPOSE=Y
DEFAULT_DOCKER_COMPOSE_VERSION=1.23.2

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
  if [ -z $INSTALLATION_PATH ]; then
    INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
  fi
fi

if [ -z $DOCKER ]; then
  typeset -u DOCKER
  read -p "$LANG_INSTALL_DOCKER[Y/N]: ($DEFAULT_DOCKER) " DOCKER
  if [ -z $DOCKER ]; then
    DOCKER=$DEFAULT_DOCKER
  fi
fi

if [ $DOCKER == 'Y' ]; then
  if [ -z $DOCKER_COMPOSE ]; then
    typeset -u DOCKER_COMPOSE
    read -p "$LANG_INSTALL_DOCKER_COMPOSE[Y/N]: ($DEFAULT_DOCKER_COMPOSE) " DOCKER_COMPOSE
    if [ -z $DOCKER_COMPOSE ]; then
      DOCKER_COMPOSE=$DEFAULT_DOCKER_COMPOSE
    fi
  fi
  if [ $DOCKER_COMPOSE == 'Y' ]; then
    if [ -z $DOCKER_COMPOSE_VERSION ]; then
      read -p "$LANG_DOCKER_COMPOSE_VERSION: ($DEFAULT_DOCKER_COMPOSE_VERSION) " DOCKER_COMPOSE_VERSION
      if [ -z $DOCKER_COMPOSE_VERSION ]; then
        DOCKER_COMPOSE_VERSION=$DEFAULT_DOCKER_COMPOSE_VERSION
      fi
    fi
  fi
fi

# Install
install_docker() {
  if [ $DOCKER != 'Y' ]; then
    return
  fi

  set -x
  curl -fsSL https://get.docker.com/ | sh # -s docker --mirror Aliyun
  # usermod -aG docker username
  # echo '{"registry-mirrors":[],"insecure-registries":[],"exec-opts":["native.cgroupdriver=systemd"]}' > /etc/docker/daemon.json
  # https://cr.console.aliyun.com/#/accelerator
  systemctl enable docker
  systemctl start docker
  set +x

  if [ $DOCKER_COMPOSE != 'Y' ]; then
    return
  fi

  set -x
  curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" > $INSTALLATION_PATH/bin/docker-compose
  chmod +x $INSTALLATION_PATH/bin/docker-compose
  set +x
}
