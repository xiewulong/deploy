#!/bin/bash
set -e

# Options
NGINX_INSTALLATION_PATH="$INSTALLATION_PATH/nginx"

if [[ -z $NGINX ]]; then
  typeset -u NGINX
  if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
    read -p "$LANG_INSTALL_NGINX[Y/N]: ($DEFAULT_NGINX) " NGINX
  fi
  if [[ -z $NGINX ]]; then
    NGINX=$DEFAULT_NGINX
  fi
fi

if [[ $NGINX == 'Y' && -d $NGINX_INSTALLATION_PATH ]]; then
  typeset -u NGINX
  if [[ -z $NGINX_OVERWRITE ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_NGINX_OVERWRITE[Y/N]: ($DEFAULT_NGINX_OVERWRITE) " NGINX
    fi
    if [[ -z $NGINX ]]; then
      NGINX=$DEFAULT_BIND_OVERWRITE
    fi
  else
    NGINX=$NGINX_OVERWRITE
  fi
fi

if [[ $NGINX == 'Y' ]]; then
  if [[ -z $NGINX_VERSION ]]; then
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_NGINX_VERSION: ($DEFAULT_NGINX_VERSION) " NGINX_VERSION
    fi
    if [[ -z $NGINX_VERSION ]]; then
      NGINX_VERSION=$DEFAULT_NGINX_VERSION
    fi
  fi
  if [[ -z $NGINX_WITH_PASSENGER ]]; then
    typeset -u NGINX_WITH_PASSENGER
    if [[ $DEFAULT_INSTALLATION_MODE != 'Y' ]]; then
      read -p "$LANG_NGINX_WITH_PASSENGER[Y/N]: ($DEFAULT_NGINX_WITH_PASSENGER) " NGINX_WITH_PASSENGER
    fi
    if [[ -z $NGINX_WITH_PASSENGER ]]; then
      NGINX_WITH_PASSENGER=$DEFAULT_NGINX_WITH_PASSENGER
    fi
  fi
  if [[ $NGINX_WITH_PASSENGER == 'Y' ]]; then
    PASSENGER=Y
    source "$CSD/applications/passenger.sh"
  fi
fi

# Install
install_nginx() {
  if [[ $NGINX != 'Y' ]]; then
    return
  fi

  CONFIGURE_OPTIONS="
                      --prefix=$NGINX_INSTALLATION_PATH
                      --with-http_ssl_module
                      --with-http_realip_module
                      --with-http_addition_module
                      --with-http_sub_module
                      --with-http_dav_module
                      --with-http_flv_module
                      --with-http_mp4_module
                      --with-http_gunzip_module
                      --with-http_gzip_static_module
                      --with-http_random_index_module
                      --with-http_secure_link_module
                      --with-http_stub_status_module
                      --with-http_auth_request_module
                      --with-http_xslt_module=dynamic
                      --with-http_image_filter_module=dynamic
                      --with-http_geoip_module=dynamic
                      --with-threads
                      --with-stream
                      --with-stream_ssl_module
                      --with-stream_ssl_preread_module
                      --with-stream_realip_module
                      --with-stream_geoip_module=dynamic
                      --with-http_slice_module
                      --with-mail
                      --with-mail_ssl_module
                      --with-compat
                      --with-file-aio
                      --with-http_v2_module
                    "

  if [[ $NGINX_WITH_PASSENGER == 'Y' ]]; then
    install_passenger
    source /etc/profile.d/ruby.sh
    source /etc/profile.d/passenger.sh
    CONFIGURE_OPTIONS="
                        $CONFIGURE_OPTIONS
                        --add-dynamic-module=`passenger-config --nginx-addon-dir`
                      "
  fi

  set -x
  if [[ -d $NGINX_INSTALLATION_PATH ]]; then
    mv $NGINX_INSTALLATION_PATH "$NGINX_INSTALLATION_PATH.`date +%Y%m%d%H%M%S`"
  fi
  # if [[ ! -f "nginx-$NGINX_VERSION.tar.gz" ]]; then
  #   curl --compressed -fLO "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
  # else
  if [[ -f "nginx-$NGINX_VERSION.tar.gz" ]]; then
    rm -rf "nginx-$NGINX_VERSION"
  fi
  wget -c "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
  tar zxvf "nginx-$NGINX_VERSION.tar.gz"
  cd "nginx-$NGINX_VERSION"
  ./configure $CONFIGURE_OPTIONS
  make
  make install
  cd ..
  echo "export PATH=$NGINX_INSTALLATION_PATH/sbin:"'$PATH' > /etc/profile.d/nginx.sh
  source /etc/profile.d/nginx.sh
  # curl --compressed -fLO https://github.com/xiewulong/nginx/raw/master/nginx.service.sample
  # mv nginx.service.sample /usr/lib/systemd/system/nginx.service
  # systemctl enable --now nginx
  set +x
}
