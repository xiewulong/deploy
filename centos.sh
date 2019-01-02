#!/bin/bash

# Current work directory
CWD=`pwd`

# Current script directory
CSD=$(cd `dirname $0`; pwd)

# I18n
CURRENT_LANG=${LANG%.*}
if [ -f "$CSD/i18n/$CURRENT_LANG.sh" ]; then
  source "$CSD/i18n/$CURRENT_LANG.sh"
else
  source "$CSD/i18n/en.sh"
fi

# Check permission
if [ `id -u` != '0' ]; then
  echo $LANG_NON_ROOT_ERROR
  exit 1
fi

set -e

# Applications
APPLICATIONS=(
  bind
  docker
  git
  ruby
  nginx
  node
  python3
)

# Defaults
source "$CSD/defaults.sh"

# Config
if [ -f "$CSD/config.sh" ]; then
  source "$CSD/config.sh"
fi

# Options
if [ -z $BASIC_SETUP ]; then
  typeset -u BASIC_SETUP
  read -p "$LANG_BASIC_SETUP[Y/N]: ($DEFAULT_BASIC_SETUP) " BASIC_SETUP
  if [ -z $BASIC_SETUP ]; then
    BASIC_SETUP=$DEFAULT_BASIC_SETUP
  fi
fi
if [ $BASIC_SETUP == 'Y' ]; then
  read -p "$LANG_HOSTNAME: " HOSTNAME
  read -p "$LANG_USERNAME: " USERNAME
  read -p "$LANG_TIMEOUT[>=0]($LANG_SECONDS): " TIMEOUT
fi

if [ -z $YUM_UPDATE ]; then
  typeset -u YUM_UPDATE
  read -p "$LANG_YUM_UPDATE[Y/N]: ($DEFAULT_YUM_UPDATE) " YUM_UPDATE
  if [ -z $YUM_UPDATE ]; then
    YUM_UPDATE=$DEFAULT_YUM_UPDATE
  fi
fi

if [ -z $YUM_UPGRADE ]; then
  typeset -u YUM_UPGRADE
  read -p "$LANG_YUM_UPGRADE[Y/N]: ($DEFAULT_YUM_UPGRADE) " YUM_UPGRADE
  if [ -z $YUM_UPGRADE ]; then
    YUM_UPGRADE=$DEFAULT_YUM_UPGRADE
  fi
fi

if [ -z $COMMON_LIBRARY ]; then
  typeset -u COMMON_LIBRARY
  read -p "$LANG_INSTALL_COMMON_LIBRARIES[Y/N]: ($DEFAULT_COMMON_LIBRARY) " COMMON_LIBRARY
  if [ -z $COMMON_LIBRARY ]; then
    COMMON_LIBRARY=$DEFAULT_COMMON_LIBRARY
  fi
fi

if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
  if [ -z $INSTALLATION_PATH ]; then
    INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
  fi
fi

for((i = 0, len = ${#APPLICATIONS[*]}; i < len; i++))
do
  source "$CSD/applications/${APPLICATIONS[$i]}.sh"
done

# Go to tmp directory
cd $CSD/tmp

# Install
if [ $BASIC_SETUP == 'Y' ]; then
  if [ -n "$HOSTNAME" ]; then
    set -x
    hostnamectl set-hostname $HOSTNAME
    set +x
  fi
  if [ -n "$TIMEOUT" ]; then
    set -x
    echo "TMOUT=$TIMEOUT" > /etc/profile.d/tmout.sh
    set +x
  fi
  if [ -n "$USERNAME" ]; then
    set -x
    useradd $USERNAME
    # chcon -Rt httpd_sys_rw_content_t /home/$USERNAME
    set +x
  fi
fi

if [ $YUM_UPDATE == 'Y' ]; then
  set -x
  yum -y update
  set +x
fi

if [ $YUM_UPGRADE == 'Y' ]; then
  set -x
  yum -y upgrade
  set +x
fi

if [ $COMMON_LIBRARY == 'Y' ]; then
  set -x
  yum -y install bash-completion bzip2 ca-certificates gcc gcc-c++ lrzsz make net-tools ntp redhat-lsb vim wget \
                 bison-devel curl-devel gdbm-devel gd-devel GeoIP-devel glib2-devel glibc-devel ImageMagick-devel libcurl-devel libffi-devel libxml2-devel libxslt-devel ncurses-devel openssl-devel pcre-devel readline-devel zlib-devel
  # yum -y install zip unzip emacs libcap diffutils psmisc libtool-libs file flex bison patch c-ares-devel e2fsprogs-devel gettext-devel glib2-devel gmp-devel kernel-devel krb5-devel libc-client-devel libevent-devel libicu-devel libidn-devel libjpeg-devel libmcrypt-devel libpng-devel libXpm-devel
  # yum -y installcairo cairo-devel cairomm-devel giflib-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel
  # yum -y install subversion git mariadb mariadb-devel re2c
  # yum -y install php-cli php-fpm php-bcmath php-gd php-imap php-intl php-mbstring php-mcrypt php-mysql php-pgsql php-xml php-pclzip php-pecl-apcu php-pecl-imagick php-pecl-memcache php-pecl-memcached php-pecl-sphinx
  # yum -y install ftp golang mariadb-server nodejs npm pptpd ruby siege sqlite-devel vsftpd
  set +x
fi

set -x
yum -y install wget
yum clean all
set +x

for((i = 0, len = ${#APPLICATIONS[*]}; i < len; i++))
do
  install_${APPLICATIONS[$i]}
done

# Back to current work directory
cd $CWD
