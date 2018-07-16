#!/bin/bash

# Check permission
if [ `id -u` != '0' ]; then
  echo 'Error: You must be root to run this script'
  exit 1
fi

set -e

# Default options
DEFAULT_GIT=Y
DEFAULT_GIT_REPOSITORY=N
DEFAULT_GIT_REPOSITORY_USERNAME=git

# Options
if [ -z $GIT ]; then
  typeset -u GIT
  read -p "$LANG_INSTALL_GIT[Y/N]: ($DEFAULT_GIT) " GIT
fi
if [ -z $GIT ]; then
  GIT=$DEFAULT_GIT
fi

if [ $GIT == 'Y' ]; then
  if [ -z $GIT_REPOSITORY ]; then
    typeset -u GIT_REPOSITORY
    read -p "$LANG_INSTALL_GIT_REPOSITORY[Y/N]: ($DEFAULT_GIT_REPOSITORY) " GIT_REPOSITORY
  fi
  if [ -z $GIT_REPOSITORY ]; then
    GIT_REPOSITORY=$DEFAULT_GIT_REPOSITORY
  fi
  if [ $GIT_REPOSITORY == 'Y' ]; then
    if [ -z $GIT_REPOSITORY_USERNAME ]; then
      read -p "$LANG_GIT_REPOSITORY_USERNAME: ($DEFAULT_GIT_REPOSITORY_USERNAME) " GIT_REPOSITORY_USERNAME
    fi
    if [ -z $GIT_REPOSITORY_USERNAME ]; then
      GIT_REPOSITORY_USERNAME=$DEFAULT_GIT_REPOSITORY_USERNAME
    fi
  fi
fi

# Install
install_git() {
  if [ $GIT != 'Y' ]; then
    return
  fi

  set -x
  yum -y install git
  set +x

  if [ $GIT_REPOSITORY != 'Y' ]; then
    return
  fi

  set -x
  useradd -s /bin/git-shell "$GIT_REPOSITORY_USERNAME"
  mkdir -m 700 "/home/$GIT_REPOSITORY_USERNAME/.ssh"
  touch "/home/$GIT_REPOSITORY_USERNAME/.ssh/authorized_keys"
  chmod 600 "/home/$GIT_REPOSITORY_USERNAME/.ssh/authorized_keys"
  chown $GIT_REPOSITORY_USERNAME:$GIT_REPOSITORY_USERNAME -R "/home/$GIT_REPOSITORY_USERNAME/.ssh"
  set +x
}
