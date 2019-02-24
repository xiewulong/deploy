#!/bin/bash
set -e

# Options
if [[ -z $KUBERNETES ]]; then
  typeset -u KUBERNETES
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_KUBERNETES[Y/N]: ($DEFAULT_KUBERNETES) " KUBERNETES
  fi
  if [[ -z $KUBERNETES ]]; then
    KUBERNETES=$DEFAULT_KUBERNETES
  fi
fi

if [[ $KUBERNETES == 'Y' ]]; then
  if [[ -z $KUBERNETES_INSTALLATION_SOURCE ]]; then
    typeset -u KUBERNETES_INSTALLATION_SOURCE
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      echo "$LANG_PLEASE_SELECT$LANG_KUBERNETES_INSTALLATION_SOURCE:"
      echo "0. $LANG_GOOGLE"
      echo "1. $LANG_ALIYUN"
      read -p "$LANG_PLEASE_INPUT_INDEX: ($DEFAULT_KUBERNETES_INSTALLATION_SOURCE) " KUBERNETES_INSTALLATION_SOURCE
    fi
    if [[ -z $KUBERNETES_INSTALLATION_SOURCE ]]; then
      KUBERNETES_INSTALLATION_SOURCE=$DEFAULT_KUBERNETES_INSTALLATION_SOURCE
    fi
  fi
fi

# Install
install_KUBERNETES() {
  if [[ $KUBERNETES != 'Y' ]]; then
    return
  fi

  KUBERNETES_INSTALLATION_SOURCE_HOST=https://packages.cloud.google.com
  case $KUBERNETES_INSTALLATION_SOURCE in
    1)
      KUBERNETES_INSTALLATION_SOURCE_HOST=https://mirrors.aliyun.com/kubernetes
      ;;
  esac

  set -x

  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
  [kubernetes]
  name=Kubernetes
  baseurl=$KUBERNETES_INSTALLATION_SOURCE_HOST/yum/repos/kubernetes-el7-x86_64
  enabled=1
  gpgcheck=1
  repo_gpgcheck=1
  gpgkey=$KUBERNETES_INSTALLATION_SOURCE_HOST/yum/doc/yum-key.gpg $KUBERNETES_INSTALLATION_SOURCE_HOST/yum/doc/rpm-package-key.gpg
  exclude=kube*
  EOF

  setenforce 0
  sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

  yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

  systemctl enable --now kubelet

  set +x
}
