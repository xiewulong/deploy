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
  docker
  filebeat
  git
  ruby
  nginx
  node
  python3
)

# Default options
DEFAULT_BASIC_SETUP=N
DEFAULT_COMMON_LIBRARY=N
DEFAULT_INSTALLATION_PATH=/usr/local
DEFAULT_YUM_UPDATE=N
DEFAULT_YUM_UPGRADE=N

# Options
if [ -z $BASIC_SETUP ]; then
  typeset -u BASIC_SETUP
  read -p "$LANG_BASIC_SETUP[Y/N]: ($DEFAULT_BASIC_SETUP) " BASIC_SETUP
fi
if [ -z $BASIC_SETUP ]; then
  BASIC_SETUP=$DEFAULT_BASIC_SETUP
fi
if [ $BASIC_SETUP == 'Y' ]; then
  read -p "$LANG_HOSTNAME: " HOSTNAME
  read -p "$LANG_USERNAME: " USERNAME
  read -p "$LANG_TIMEOUT[>=0]($LANG_SECONDS): " TIMEOUT
fi

if [ -z $YUM_UPDATE ]; then
  typeset -u YUM_UPDATE
  read -p "$LANG_YUM_UPDATE[Y/N]: ($DEFAULT_YUM_UPDATE) " YUM_UPDATE
fi
if [ -z $YUM_UPDATE ]; then
  YUM_UPDATE=$DEFAULT_YUM_UPDATE
fi

if [ -z $YUM_UPGRADE ]; then
  typeset -u YUM_UPGRADE
  read -p "$LANG_YUM_UPGRADE[Y/N]: ($DEFAULT_YUM_UPGRADE) " YUM_UPGRADE
fi
if [ -z $YUM_UPGRADE ]; then
  YUM_UPGRADE=$DEFAULT_YUM_UPGRADE
fi

if [ -z $COMMON_LIBRARY ]; then
  typeset -u COMMON_LIBRARY
  read -p "$LANG_INSTALL_COMMON_LIBRARIES[Y/N]: ($DEFAULT_COMMON_LIBRARY) " COMMON_LIBRARY
fi
if [ -z $COMMON_LIBRARY ]; then
  COMMON_LIBRARY=$DEFAULT_COMMON_LIBRARY
fi

if [ -z $INSTALLATION_PATH ]; then
  read -p "$LANG_COMMON_INSTALLATION_PATH: ($DEFAULT_INSTALLATION_PATH) " INSTALLATION_PATH
fi
if [ -z $INSTALLATION_PATH ]; then
  INSTALLATION_PATH=$DEFAULT_INSTALLATION_PATH
fi

for((i = 0, len = ${#APPLICATIONS[*]}; i < len; i++))
do
  source "$CSD/applications/${APPLICATIONS[$i]}.sh"
done

# Go to tmp directory
cd $CSD/tmp

# Install
set -x

if [ $BASIC_SETUP == 'Y' ]; then
  if [ -n "$HOSTNAME" ]; then
    hostnamectl set-hostname $HOSTNAME
  fi
  if [ -n "$TIMEOUT" ]; then
    echo "TMOUT=$TIMEOUT" > /etc/profile.d/tmout.sh
  fi
  if [ -n "$USERNAME" ]; then
    useradd $USERNAME
    # chcon -Rt httpd_sys_rw_content_t /home/$USERNAME
  fi
fi

if [ $YUM_UPDATE == 'Y' ]; then
  yum -y update
fi
if [ $YUM_UPGRADE == 'Y' ]; then
  yum -y upgrade
fi
if [ $COMMON_LIBRARY == 'Y' ]; then
  yum -y install bash-completion curl gcc gcc-c++ lrzsz make net-tools ntp redhat-lsb vim* wget
  # yum -y install zip unzip emacs libcap diffutils ca-certificates psmisc libtool-libs file flex bison patch bzip2 bzip2-devel c-ares-devel curl-devel e2fsprogs-devel gd-devel gettext-devel GeoIP-devel glib2-devel gmp-devel kernel-devel krb5-devel libc-client-devel libcurl-devel libevent-devel libicu-devel libidn-devel libjpeg-devel libmcrypt-devel libpng-devel libxml2-devel libXpm-devel libxslt-devel ncurses-devel openssl-devel pcre-devel zlib-devel ImageMagick-devel \
  # yum -y installcairo cairo-devel cairomm-devel giflib-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel \
  # yum -y installsubversion git mariadb mariadb-devel re2c
  # yum -y install php-cli php-fpm php-bcmath php-gd php-imap php-intl php-mbstring php-mcrypt php-mysql php-pgsql php-xml php-pclzip php-pecl-apcu php-pecl-imagick php-pecl-memcache php-pecl-memcached php-pecl-sphinx
  # yum -y install ftp golang mariadb-server nodejs npm pptpd ruby siege sqlite-devel vsftpd
fi

yum clean all
set +x

for((i = 0, len = ${#APPLICATIONS[*]}; i < len; i++))
do
  install_${APPLICATIONS[$i]}
done

# Back to current work directory
cd $CWD
