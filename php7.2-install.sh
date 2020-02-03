#!/bin/sh

#author: Aysad Kozanoglu
#email: aysadx@gmail.com

#
# QUICK launch script
# wget -O - https://git.io/JvLZx | bash
#

# apt-get -y remove php5* --purge

PHPPACKS="php7.3 php7.3-mysql php7.3-mbstring php7.3-xml php7.3-zip php7.3-intl php7.3-gd php7.3-fpm php7.3-json php7.3-curl "

echo -e "installing php7 "

apt install -y --yes ca-certificates apt-transport-https 

wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt update &&  apt install --no-install-recommends  -y --yes php7.3 $PHPPACKS
