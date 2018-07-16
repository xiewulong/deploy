#!/bin/bash

# Check permission
if [ `id -u` != '0' ]; then
  echo 'Error: You must be root to run this script'
  exit 1
fi

# Config
dir=$(cd `dirname $0`; pwd)
installation_path='/usr/local'
# version_epel='7-9'
version_ruby='2.5.1'
version_passenger='5.3.1'
version_nginx='1.14.0'
version_php='7.2.1'
version_docker_compose='1.21.2'
version_node='8.11.2'
version_mongodb='3.6.2'
version_python3='3.6.4'
user_http='www'
user_git='git'

# Installer
function installer() {
  wget -c $3
  tar zxvf $2
  mv $1 $4
}

# Source installer
function sourceInstaller() {
  wget -c $3
  tar zxvf $2
  cd $1
  ./configure $4
  make && make install
  $5
  cd ..
  rm -rf $1 $2
}

set -ex

# Go to root directory
cd

# ================== Hostname ==================
# hostnamectl set-hostname ${user_http}

# ================== Time out ==================
# echo 'TMOUT=600' > /etc/profile.d/tmout.sh

# ================== Add repo && install tools && update && upgrade ==================
# yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-${version_epel}.noarch.rpm
yum -y install epel-release yum-utils
yum-config-manager --enable epel
yum -y update
yum -y upgrade
yum -y install  autoconf bash-completion curl gcc gcc-c++ lrzsz make net-tools ntp redhat-lsb vim* wget \
                zip unzip emacs libcap diffutils ca-certificates psmisc libtool-libs file flex bison patch bzip2 bzip2-devel c-ares-devel curl-devel e2fsprogs-devel gd-devel gettext-devel GeoIP-devel glib2-devel gmp-devel kernel-devel krb5-devel libc-client-devel libcurl-devel libevent-devel libicu-devel libidn-devel libjpeg-devel libmcrypt-devel libpng-devel libxml2-devel libXpm-devel libxslt-devel ncurses-devel openssl-devel pcre-devel zlib-devel ImageMagick-devel \
                cairo cairo-devel cairomm-devel giflib-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel \
                subversion git mariadb mariadb-devel re2c
# yum -y install php-cli php-fpm php-bcmath php-gd php-imap php-intl php-mbstring php-mcrypt php-mysql php-pgsql php-xml php-pclzip php-pecl-apcu php-pecl-imagick php-pecl-memcache php-pecl-memcached php-pecl-sphinx
# yum -y install ftp golang mariadb-server nodejs npm pptpd ruby siege sqlite-devel vsftpd
yum clean all

# ================== ${user_http} ==================
useradd ${user_http}
# chcon -Rt httpd_sys_rw_content_t /home/${user_http}

# ================== Vsftpd ==================
# cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.sample
# cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd.sample
# sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
# sed -i 's/#anon_upload_enable=YES/anon_upload_enable=YES/g' /etc/vsftpd/vsftpd.conf
# sed -i 's/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=YES/g' /etc/vsftpd/vsftpd.conf
# sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd/vsftpd.conf
# sed -i 's/listen=NO/listen=YES/g' /etc/vsftpd/vsftpd.conf
# sed -i 's/listen_ipv6=YES/#listen_ipv6=YES/g' /etc/vsftpd/vsftpd.conf
# echo 'anon_umask=002' >> /etc/vsftpd/vsftpd.conf
# echo 'anon_other_write_enable=YES' >> /etc/vsftpd/vsftpd.conf
# echo 'allow_writeable_chroot=YES' >> /etc/vsftpd/vsftpd.conf
# echo 'guest_enable=YES' >> /etc/vsftpd/vsftpd.conf
# echo 'guest_username=ftp' >> /etc/vsftpd/vsftpd.conf
# echo 'auth required /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser' > /etc/pam.d/vsftpd
# echo 'account required /lib64/security/pam_userdb.so db=/etc/vsftpd/vuser' >> /etc/pam.d/vsftpd
# echo '#db_load -Tt hash -f /etc/vsftpd/vuser.conf /etc/vsftpd/vuser.db' > /etc/vsftpd/vuser.conf
# chown ftp:ftp -R /var/ftp
# setsebool -P ftp_home_dir=1 ftpd_full_access=1

# ================== Ruby ==================
name="ruby-${version_ruby}"
tar="${name}.tar.gz"
path="${installation_path}/ruby"
sourceInstaller ${name} ${tar} https://cache.ruby-lang.org/pub/ruby/${version_ruby%.*}/${tar} " --prefix=${path}"
${path}/bin/gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
${path}/bin/gem update --system
${path}/bin/gem install rails
bundle config mirror.https://rubygems.org https://gems.ruby-china.org
# echo "export PATH=${path}/bin:"'$PATH' > /etc/profile.d/ruby.sh
# source /etc/profile.d/ruby.sh

# ================== Passenger ==================
name="passenger-${version_passenger}"
tar="${name}.tar.gz"
path="${installation_path}/passenger"
installer ${name} ${tar} http://s3.amazonaws.com/phusion-passenger/releases/${tar} ${path}
# echo "export PATH=${path}/bin:"'$PATH' > /etc/profile.d/passenger.sh
# source /etc/profile.d/passenger.sh
passenger_nginx_addon_dir=$($path/bin/passenger-config --nginx-addon-dir)

# ================== Nginx ==================
name="nginx-${version_nginx}"
tar="${name}.tar.gz"
path="${installation_path}/nginx"
sourceInstaller ${name} ${tar} http://nginx.org/download/${tar} " --prefix=${path} --user=${user_http} --group=${user_http} --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-http_slice_module --with-mail --with-mail_ssl_module --with-compat --with-file-aio --with-http_v2_module --add-dynamic-module=${passenger_nginx_addon_dir}"
# echo "export PATH=${path}/sbin:"'$PATH' > /etc/profile.d/nginx.sh
# source /etc/profile.d/nginx.sh
# setsebool -P httpd_can_network_connect=1
# wget -c https://github.com/xiewulong/nginx/raw/master/nginx.service.sample
# mv nginx.service.sample /usr/lib/systemd/system/nginx.service

# ================== Php ==================
name="php-${version_php}"
tar="${name}.tar.gz"
path="${installation_path}/php"
sourceInstaller ${name} ${tar} http://cn2.php.net/distributions/${tar} " --prefix=${path} --with-config-file-path=${path}/etc --enable-fpm --with-fpm-user=${user_http} --with-fpm-group=${user_http} --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=${installation_path}/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --enable-opcache --with-xsl" "cp php.ini-development php.ini-production ${path}/etc/"
# echo "export PATH=${path}/sbin:${path}/bin:"'$PATH' > /etc/profile.d/php.sh
# source /etc/profile.d/php.sh
cp ${path}/etc/php-fpm.conf.default ${path}/etc/php-fpm.conf
cp ${path}/etc/php.ini-production ${path}/etc/php.ini
cp ${path}/etc/php-fpm.d/www.conf.default ${path}/etc/php-fpm.d/www.conf
sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${path}/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${path}/etc/php.ini
sed -i 's/expose_php =.*/expose_php = Off/g' ${path}/etc/php.ini
sed -i 's/post_max_size =.*/post_max_size = 60M/g' ${path}/etc/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 60M/g' ${path}/etc/php.ini
sed -i 's/max_execution_time =.*/max_execution_time = 120/g' ${path}/etc/php.ini
sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${path}/etc/php.ini
pear config-set php_ini ${path}/etc/php.ini
pecl config-set php_ini ${path}/etc/php.ini
# pecl install apcu imagick memcache memcached swoole
# mkdir -p /var/lib/php/session
# chown ${user_http}:${user_http} /var/lib/php/session
wget -c https://github.com/xiewulong/deploy/raw/master/systemd/php-fpm.service
mv php-fpm.service /usr/lib/systemd/system/

# ================== Composer ==================
curl -sS https://getcomposer.org/installer | php -- --install-dir=${installation_path}/bin --filename=composer
# composer global require 'fxp/composer-asset-plugin:~1.2.0'

# ================== Docker ==================
# curl -fsSL https://get.docker.com/ | sh
# usermod -aG docker username
# echo '{"registry-mirrors":[],"insecure-registries":[],"exec-opts":["native.cgroupdriver=systemd"]}' > /etc/docker/daemon.json
# https://cr.console.aliyun.com/#/accelerator

# ================== Docker-compose ==================
# curl -L https://github.com/docker/compose/releases/download/${version_docker_compose}/docker-compose-`uname -s`-`uname -m` > ${installation_path}/bin/docker-compose
# chmod +x ${installation_path}/bin/docker-compose

# ================== Node ==================
# name="node-v${version_node}"
# tar="${name}.tar.gz"
# path="${installation_path}/node"
# installer ${name} ${name}-linux-x64.tar.xz https://nodejs.org/dist/v${version_node}/${name}-linux-x64.tar.xz ${path}
# sourceInstaller ${name} ${tar} https://nodejs.org/dist/v${version_node}/${tar} " --prefix=${path}"
# echo "export PATH=${path}/bin:"'$PATH' > /etc/profile.d/node.sh
# source /etc/profile.d/node.sh
# ${path}/bin/npm install -g --registry=https://registry.npm.taobao.org cnpm
# ${path}/bin/cnpm install -g pm2 yarn

# ================== Mongodb ==================
# name="mongodb-linux-x86_64-rhel70-${version_mongodb}"
# tar="${name}.tgz"
# path="${installation_path}/mongodb"
# installer ${name} ${tar} https://fastdl.mongodb.org/linux/${tar} ${path}
# echo "export PATH=${path}/bin:"'$PATH' > /etc/profile.d/mongodb.sh
# source /etc/profile.d/mongodb.sh

# ================== Python 3 ==================
# name="Python-${version_python3}"
# tar="${name}.tgz"
# path="${installation_path}/python3"
# sourceInstaller ${name} ${tar} https://www.python.org/ftp/python/${version_python3}/${tar} " --prefix=${path}"
# ln -sf ${path}/bin/pydoc3 ${installation_path}/bin/pydoc3
# ln -sf ${path}/bin/python3 ${installation_path}/bin/python3

# ================== Git ==================
# useradd -s /bin/git-shell ${user_git}
# mkdir -m 700 /home/${user_git}/.ssh
# touch /home/${user_git}/.ssh/authorized_keys
# chmod 600 /home/${user_git}/.ssh/authorized_keys
# chown git:git -R /home/${user_git}/.ssh

# ================== Systemctl ==================
# systemctl enable vsftpd
# systemctl start vsftpd
# systemctl enable nginx
# systemctl start nginx
systemctl enable php-fpm
systemctl start php-fpm
# systemctl enable docker
# systemctl start docker
# systemctl enable pptpd
# systemctl start pptpd
# systemctl enable firewalld
# systemctl start firewalld

# ================== Pptpd ==================
# echo 'localip 192.168.192.168' >> /etc/pptpd.conf
# echo 'remoteip 192.168.192.68-167' >> /etc/pptpd.conf
# echo 'logfile /var/log/pptpd.log' >> /etc/ppp/options.pptpd
# echo 'ms-dns 8.8.8.8' >> /etc/ppp/options.pptpd
# echo 'ms-dns 8.8.4.4' >> /etc/ppp/options.pptpd
# echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
# sysctl -p
# firewall-cmd --permanent --add-port=1723/tcp
# firewall-cmd --permanent --add-masquerade
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p gre -j ACCEPT
# firewall-cmd --reload
# systemctl restart pptpd

# Back
cd $dir