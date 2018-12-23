#author: Aysad Kozanoglu
#email: aysadx@gmail.com
# Debian Jessie
# QUICK LAUNCH script
# wget -O - https://git.io/fpuhU | bash
#
apt-get -y -qq install software-properties-common

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db

add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://www.ftp.saix.net/DB/mariadb/repo/10.1/debian  jessie main'

apt-get update

echo "installing mariaDB"

apt-get -qq -y install mariadb-server mariadb-client

wget -O /etc/mysql/my.cnf "https://git.io/fpuxX"

systemctl restart mysql; systemctl status mysql 

echo -e "\n execute mysql_secure_installation to set your root password, actually blank!! \n"
