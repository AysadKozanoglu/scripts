#!/bin/sh

#author: Aysad Kozanoglu
#email: aysadx@gmail.com

#
# QUICK launch script
# wget -O - https://git.io/JvLZx | bash
#

# apt-get -y remove php5* --purge

PHPPACKS="php7.2 php7.2-mysql php7.2-mbstring php7.2-xml php7.2-zip php7.2-intl php7.2-gd php7.2-fpm php7.2-json php7.2-curl "

echo -e "installing php7 "

apt install -y --yes ca-certificates apt-transport-https 

wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt update && apt install php7.2 # apt install php7.3

apt install -y --yes $PHPPACKS
