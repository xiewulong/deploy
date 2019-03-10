#!/bin/bash
set -e

# Options
HELM_INSTALLATION_PATH="$INSTALLATION_PATH/helm"

if [[ -z $HELM ]]; then
  typeset -u HELM
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_HELM[Y/N]: ($DEFAULT_HELM) " HELM
  fi
  if [[ -z $HELM ]]; then
    HELM=$DEFAULT_HELM
  fi
fi

if [[ $HELM == 'Y' && -d $HELM_INSTALLATION_PATH ]]; then
  typeset -u HELM
  if [[ -z $HELM_OVERWRITE ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_HELM_OVERWRITE[Y/N]: ($DEFAULT_HELM_OVERWRITE) " HELM
    fi
    if [[ -z $HELM ]]; then
      HELM=$DEFAULT_HELM_OVERWRITE
    fi
  else
    HELM=$HELM_OVERWRITE
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
  if [[ -d $HELM_INSTALLATION_PATH ]]; then
    mv $HELM_INSTALLATION_PATH "$HELM_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  mkdir $HELM_INSTALLATION_PATH
  if [[ -f "helm-v$HELM_VERSION-linux-amd64.tar.gz" ]]; then
    rm -rf "helm-v$HELM_VERSION-linux-amd64"
  fi
  wget -c "https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz"
  tar zxvf "helm-v$HELM_VERSION-linux-amd64.tar.gz"
  mv linux-amd64 "helm-v$HELM_VERSION-linux-amd64"
  mv "helm-v$HELM_VERSION-linux-amd64/helm" "helm-v$HELM_VERSION-linux-amd64/tiller" $HELM_INSTALLATION_PATH/
  echo "export PATH=$NODE_INSTALLATION_PATH:"'$PATH' > /etc/profile.d/helm.sh
  source /etc/profile.d/helm.sh
  set +x
}
