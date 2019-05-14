# author: Aysad Kozanoglu
# email: aysadx@gmail.com
#
#    * RHEL/CentOS 6 & 7
#    * Ubuntu 14.04 LTS (trusty), 16.04 LTS (xenial), & 18.04 LTS (bionic)
#    * Debian 8 (jessie) & 9 (stretch)
#    * SLES 12 & 15"

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
