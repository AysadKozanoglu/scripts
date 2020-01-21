# author: Aysad Kozanoglu
# email: aysadx@gmail.com
#
#    * RHEL/CentOS 6 & 7
#    * Ubuntu 14.04 LTS (trusty), 16.04 LTS (xenial), & 18.04 LTS (bionic)
#    * Debian 8 (jessie) & 9 (stretch)
#    * SLES 12 & 15"

#apt-get -y -qq install software-properties-common

# install repo mariadb
# see source 
# https://github.com/AysadKozanoglu/scripts/blob/master/mariadb_install_repo.sh

#wget -O - https://git.io/fjWjZ | bash
#echo "installing mariaDB"
#apt-get update && apt-get -qq -y install mariadb-server mariadb-client
#wget -O /etc/mysql/my.cnf "https://git.io/fpuxX"
#systemctl restart mysql; systemctl status mysql 

repo="10.5"
mirror="http://mirror.i3d.net/pub/mariadb/repo"

if [ -e /usr/bin/mysql ] ; then
	echo "MySQL or MariaDB is already installed"
	exit;
fi

amiroot () {
	if [[ "$EUID" -ne 0 ]]; then
		echo "  Sorry, you need to run this as root"
		exit;
	fi
}

# Detect OS
detectOS () {
	OS=`uname`
	if [ "$OS" = "Linux" ] ; then
		if [ -f /etc/redhat-release ] ; then
			centOS;
		elif [ -f /etc/debian_version ] ; then
			debian;
		elif [ -f /etc/SuSE-release ] ; then
			zypper install mariadb
			exit;
		elif [ -f /etc/arch-release ] ; then
			pacman -S mariadb
			systemctl enable mysqld.service
			systemctl start mysqld.service
			exit;
		fi
	else
		echo "unknown os"
		exit;
	fi
}

# Install on Debian/Ubuntu
debian () {
	# Check if sudo exists
	if [ ! -e /usr/bin/sudo ] ; then
		apt-get install sudo -y
	fi

	dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

	# Check if Ubuntu
	if [ "$dist" == "Ubuntu" ]; then
		debOS=ubuntu
		arch="arch=amd64,i386,ppc64el"
	else
		debOS=debian
		arch="arch=amd64,i386"
	fi

	# Find debian codename
	codename=`lsb_release -c | cut -f2`

	if [ "$codename" == "precise" ]; then
		arch="arch=amd64,i386"
	fi

	# Install MariaDB
	sudo apt-get install python-software-properties -y
	sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
	sudo add-apt-repository "deb [$arch] $mirror/$repo/$debOS $codename main"
	sudo apt-get update -y
	sudo apt-get install mariadb-server -y --allow-unauthenticated
	exit;
}

# Install on CentOS
centOS () {
	# Check if sudo exists
	if [ ! -e /usr/bin/sudo ] ; then
		yum install sudo -y
	fi

	rm -f /etc/yum.repos.d/MariaDB.repo

	# OS bits information
	cpubits=`uname -m`
	if [ "$cpubits" == 'x86_64' ]; then
		bits=amd64
	else
		bits=x86
	fi

	# Check what version is CentOS
	isFedora=`cat /etc/*release* | grep ^ID= | cut -d "=" -f 2`

	# Check if Fedora
	if [ "$isFedora" == "fedora" ]; then
		fedora;
	fi

	osversion=`rpm -q --queryformat '%{VERSION}\n' centos-release`

	sudo yum update -y

	echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/$repo/centos$osversion-$bits
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

	# Install MariaDB
	sudo yum install MariaDB-server MariaDB-client -y
	exit;
}

# Install on Fedora
fedora () {
	# Check what version is Fedora
	osversion=`rpm -q --queryformat '%{VERSION}\n' fedora-release`

	# Check if Fedora version is lower than 22
	if [ $osversion -lt 22 ]; then
		echo "unsupported fedora version"
		echo "fedora 22 and above is supported"
		exit;
	fi

	sudo dnf update -y

	echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/$repo/fedora$osversion-$bits
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

	# Install MariaDB
	sudo dnf install MariaDB-server -y
	exit;
}

# See how we were called.
case $1 in
	*)
		amiroot; detectOS;;
esac
exit 1


echo -e "\n execute mysql_secure_installation to set your root password, actually blank!! \n"
