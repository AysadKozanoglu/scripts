#!/bin/sh

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
