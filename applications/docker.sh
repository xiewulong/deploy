#!/bin/bash

set -e

# Options
if [ -z $DOCKER ]; then
  typeset -u DOCKER
  if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
    read -p "$LANG_INSTALL_DOCKER[Y/N]: ($DEFAULT_DOCKER) " DOCKER
  fi
  if [ -z $DOCKER ]; then
    DOCKER=$DEFAULT_DOCKER
  fi
fi

if [ $DOCKER == 'Y' ]; then
  if [ -z $DOCKER_COMPOSE ]; then
    typeset -u DOCKER_COMPOSE
    if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
      read -p "$LANG_INSTALL_DOCKER_COMPOSE[Y/N]: ($DEFAULT_DOCKER_COMPOSE) " DOCKER_COMPOSE
    fi
    if [ -z $DOCKER_COMPOSE ]; then
      DOCKER_COMPOSE=$DEFAULT_DOCKER_COMPOSE
    fi
  fi
  if [ $DOCKER_COMPOSE == 'Y' ]; then
    if [ -z $DOCKER_COMPOSE_VERSION ]; then
      if [ $DEFAULT_INSTALLATION_MODE != 'Y' ]; then
        read -p "$LANG_DOCKER_COMPOSE_VERSION: ($DEFAULT_DOCKER_COMPOSE_VERSION) " DOCKER_COMPOSE_VERSION
      fi
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
