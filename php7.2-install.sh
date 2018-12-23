#!/bin/sh

#author: Aysad Kozanoglu
#email: aysadx@gmail.com

#
# QUICK launch script
# wget -O - https://git.io/fpuND | bash
#

# apt-get -y remove php5* --purge

echo -e "installing php7 "

apt install ca-certificates apt-transport-https curl wget 

wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
# curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -

echo "deb https://packages.sury.org/php/ jessie main" > /etc/apt/sources.list.d/php.list

apt-get update && apt-get -y install php7.2 php7.2-fpm php7.2-common php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-mysql php7.2-xml

php -m; php -v

/etc/init.d/php7.2-fpm start

# fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
