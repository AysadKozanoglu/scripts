#!/bin/sh

#author: Aysad Kozanoglu
#email: aysadx@gmail.com

# QUICK LAUNCH script
# wget -O - https://git.io/fpuAV | bash
#
# check before running this script if nginx is running or apache is installed
# if yes then remove/disable them

   NGINXVER=nginx-1.16.1
     OSSLVER=openssl-1.1.1c.tar.gz
  SOURCEPATH=/source
  
  if [ ! -d "$SOURCEPATH" ]; 
   then 
     mkdir $SOURCEPATH;
  fi
  
echo -e "install core packages...\n"

apt-get -qq -y install build-essential git libpcre3 libpcre3-dev zlib1g zlib1g-dev

cd $SOURCEPATH

echo -e "downloading packages $NGINXVER and  $OSSLVER "

wget -q http://nginx.org/download/${NGINXVER}.tar.gz; wget -q https://www.openssl.org/source/old/1.1.1/${OSSLVER}.tar.gz

echo -e "extracting packages $NGINXVER and  $OSSLVER "

tar zxvf nginx*.tar.gz; tar zxvf openssl*.tar.gz 

cd $SOURCEPATH/$NGINXVER && ./configure --with-stream --with-threads --with-file-aio --with-http_stub_status_module --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --with-ld-opt=-Wl,-z,relro --sbin-path=/usr/local/sbin --with-http_stub_status_module --with-http_ssl_module --user=www-data --group=www-data --with-openssl=$SOURCEPATH/$OSSLVER
make && make install

wget -O /usr/local/nginx/conf/nginx.conf "https://git.io/fpuNz"

nginx

echo -e "nginx installed\n"
