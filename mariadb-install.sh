#author: Aysad Kozanoglu
#email: aysadx@gmail.com
# Debian Jessie
# QUICK LAUNCH script
# wget -O - https://git.io/fjWjB | bash
#
apt-get -y -qq install software-properties-common

# install repo mariadb
# see source 
# https://github.com/AysadKozanoglu/scripts/blob/master/mariadb_install_repo.sh
wget -O - https://git.io/fjWjZ | bash

echo "installing mariaDB"

apt-get update && apt-get -qq -y install mariadb-server mariadb-client

wget -O /etc/mysql/my.cnf "https://git.io/fpuxX"

systemctl restart mysql; systemctl status mysql 

echo -e "\n execute mysql_secure_installation to set your root password, actually blank!! \n"
