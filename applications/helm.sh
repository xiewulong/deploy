#!/bin/bash
set -e

# Options
if [[ -z $HELM ]]; then
  typeset -u HELM
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_HELM[Y/N]: ($DEFAULT_HELM) " HELM
  fi
  if [[ -z $HELM ]]; then
    HELM=$DEFAULT_HELM
  fi
fi

if [[ $HELM == 'Y' ]]; then
  if [[ -z $HELM_VERSION ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_HELM_VERSION: ($DEFAULT_HELM_VERSION) " HELM_VERSION
    fi
    if [[ -z $HELM_VERSION ]]; then
      HELM_VERSION=$DEFAULT_HELM_VERSION
    fi
  fi
fi

# Install
install_helm() {
  if [[ $HELM != 'Y' ]]; then
    return
  fi

  set -x
  if [[ -f "helm-v$HELM_VERSION-linux-amd64.tar.gz" ]]; then
    rm -rf "helm-v$HELM_VERSION-linux-amd64"
  fi
  wget -c "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz"
  tar zxvf "helm-v$HELM_VERSION-linux-amd64.tar.gz"
  mv linux-amd64 "helm-v$HELM_VERSION-linux-amd64"
  mkdir $HELM_INSTALLATION_PATH
  mv "helm-v$HELM_VERSION-linux-amd64/helm" /usr/local/bin/ -f
  set +x
}
