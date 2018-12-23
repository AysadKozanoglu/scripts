#!/bin/sh
# Author: Aysad Kozanoglu
# Quick Launch:
# wget -O composer-install.sh "https://git.io/fhJaj" && sh composer-install.sh

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
composer -v
