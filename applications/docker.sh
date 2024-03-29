#!/bin/bash
set -e

# Options
if [[ -z $DOCKER ]]; then
  typeset -u DOCKER
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_DOCKER[Y/N]: ($DEFAULT_DOCKER) " DOCKER
  fi
  if [[ -z $DOCKER ]]; then
    DOCKER=$DEFAULT_DOCKER
  fi
fi

if [[ $DOCKER == 'Y' ]]; then
  if [[ -z $DOCKER_VERSION ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_DOCKER_VERSION: " DOCKER_VERSION
    fi
  fi
  if [[ -z $DOCKER_INSTALLATION_SOURCE ]]; then
    typeset -u DOCKER_INSTALLATION_SOURCE
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      echo "$LANG_PLEASE_SELECT$LANG_DOCKER_INSTALLATION_SOURCE:"
      echo "0. $LANG_GOOGLE"
      echo "1. $LANG_ALIYUN"
      echo "2. $LANG_AZURE_CHINA"
      read -p "$LANG_PLEASE_INPUT_INDEX: ($DEFAULT_DOCKER_INSTALLATION_SOURCE) " DOCKER_INSTALLATION_SOURCE
    fi
    if [[ -z $DOCKER_INSTALLATION_SOURCE ]]; then
      DOCKER_INSTALLATION_SOURCE=$DEFAULT_DOCKER_INSTALLATION_SOURCE
    fi
  fi
fi

# Install
install_docker() {
  if [[ $DOCKER != 'Y' ]]; then
    return
  fi

  DOCKER_INSTALLATION_SOURCE_MIRROR=''
  case $DOCKER_INSTALLATION_SOURCE in
    1)
      DOCKER_INSTALLATION_SOURCE_MIRROR=Aliyun
      ;;
    2)
      DOCKER_INSTALLATION_SOURCE_MIRROR=AzureChinaCloud
      ;;
  esac

  set -x
  export VERSION=$DOCKER_VERSION
  curl -fsSL https://get.docker.com/ | sh -s docker --mirror $DOCKER_INSTALLATION_SOURCE_MIRROR
  # usermod -aG docker username
  # echo '{"registry-mirrors":["https://registry.docker-cn.com"],"insecure-registries":[],"exec-opts":["native.cgroupdriver=systemd"]}' > /etc/docker/daemon.json
  # https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors
  systemctl enable --now docker
  set +x
}
