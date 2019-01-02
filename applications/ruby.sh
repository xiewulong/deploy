#!/bin/bash

set -e

# Options
if [ -z $RUBY ]; then
  typeset -u RUBY
  read -p "$LANG_INSTALL_RUBY[Y/N]: ($DEFAULT_RUBY) " RUBY
  if [ -z $RUBY ]; then
    RUBY=$DEFAULT_RUBY
  fi
fi

RUBY_INSTALLATION_PATH="$INSTALLATION_PATH/ruby"
if [[ $RUBY == 'Y' && -d "$RUBY_INSTALLATION_PATH" ]]; then
  typeset -u RUBY
  read -p "$LANG_RUBY_OVERWRITE[Y/N]: ($DEFAULT_RUBY_OVERWRITE) " RUBY
  if [ -z $RUBY ]; then
    RUBY=$DEFAULT_RUBY_OVERWRITE
  fi
fi

if [ $RUBY == 'Y' ]; then
  if [ -z $RUBY_VERSION ]; then
    read -p "$LANG_RUBY_VERSION: ($DEFAULT_RUBY_VERSION) " RUBY_VERSION
    if [ -z $RUBY_VERSION ]; then
      RUBY_VERSION=$DEFAULT_RUBY_VERSION
    fi
  fi
fi

# Install
install_ruby() {
  if [ $RUBY != 'Y' ]; then
    return
  fi

  set -x
  if [ -d "$RUBY_INSTALLATION_PATH" ]; then
    mv "$RUBY_INSTALLATION_PATH" "$RUBY_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [ ! -f "ruby-$RUBY_VERSION.tar.gz" ]; then
  #   curl --compressed -fLO "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-$RUBY_VERSION.tar.gz"
  # else
  if [ -f "ruby-$RUBY_VERSION.tar.gz" ]; then
    rm -rf "ruby-$RUBY_VERSION"
  fi
  wget -c "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-$RUBY_VERSION.tar.gz"
  tar zxvf "ruby-$RUBY_VERSION.tar.gz"
  cd "ruby-$RUBY_VERSION"
  ./configure --prefix="$RUBY_INSTALLATION_PATH"
  make
  make install
  cd ..
  echo "export PATH=$RUBY_INSTALLATION_PATH/bin:"'$PATH' > /etc/profile.d/ruby.sh
  source /etc/profile.d/ruby.sh
  # gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
  # gem update --system
  # gem install rails
  # bundle config mirror.https://rubygems.org https://gems.ruby-china.com
  set +x
}
