#!/bin/bash

set -e

# Default options
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_RUBY=Y
DEFAULT_RUBY_VERSION=2.5.1

# Options
if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi
RUBY_INSTALLATION_PATH="$INSTALLATION_PATH/ruby"

if [ -z $RUBY ]; then
  typeset -u RUBY
  read -p "$LANG_INSTALL_RUBY[Y/N]: ($DEFAULT_RUBY) " RUBY
fi
if [ -z $RUBY ]; then
  RUBY=$DEFAULT_RUBY
fi
if [ $RUBY == 'Y' ]; then
  if [ -z $RUBY_VERSION ]; then
    read -p "$LANG_RUBY_VERSION: ($DEFAULT_RUBY_VERSION) " RUBY_VERSION
  fi
  if [ -z $RUBY_VERSION ]; then
    RUBY_VERSION=$DEFAULT_RUBY_VERSION
  fi
fi

# Install
install_ruby() {
  if [[ $RUBY != 'Y' || -d "$RUBY_INSTALLATION_PATH" ]]; then
    return
  fi

  set -x
  curl --compressed -fLO "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-$RUBY_VERSION.tar.gz"
  tar zxvf "ruby-$RUBY_VERSION.tar.gz"
  cd "ruby-$RUBY_VERSION"
  ./configure --prefix="$RUBY_INSTALLATION_PATH"
  make && make install
  cd ..
  rm -rf "ruby-$RUBY_VERSION" "ruby-$RUBY_VERSION.tar.gz"
  echo "export PATH=$RUBY_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/ruby.sh
  source /etc/profile.d/ruby.sh
  # gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
  # gem update --system
  # gem install rails
  # bundle config mirror.https://rubygems.org https://gems.ruby-china.org
  set +x
}
