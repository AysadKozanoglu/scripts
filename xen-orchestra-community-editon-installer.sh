#!/bin/bash
# Author: Aysad Kozanoglu
# 
# Quick Launch Installer onliner:
#  wget -O -  https://git.io/fhIr6 | bash


# Check if we were effectively run as root
[ $EUID = 0 ] || { echo "This script needs to be run as root!"; exit 1; }

# Check for 1GB Memory
totalk=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
if [ "$totalk" -lt "1000000" ]; then echo "XOCE Requires at least 1GB Memory!"; exit 1; fi 

distro=$(/usr/bin/lsb_release -is)
if [ "$distro" = "Ubuntu" ]; then /usr/bin/add-apt-repository multiverse; fi

xo_branch="master"
xo_server="https://github.com/AysadKozanoglu/xen-orchestra"
n_repo="https://raw.githubusercontent.com/visionmedia/n/master/bin/n"
yarn_repo="deb https://dl.yarnpkg.com/debian/ stable main"
node_source="https://deb.nodesource.com/setup_8.x"
yarn_gpg="https://dl.yarnpkg.com/debian/pubkey.gpg"
n_location="/usr/local/bin/n"
xo_server_dir="/opt/xen-orchestra"
systemd_service_dir="/lib/systemd/system"
xo_service="xo-server.service"

# Ensure that git and curl are installed
/usr/bin/apt-get update

/usr/bin/apt-get --yes  install build-essential redis-server libpng-dev git python-minimal nfs-common git curl
                          
curl -sL https://deb.nodesource.com/setup_8.x | bash -

apt-get install --yes nodejs

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt-get update && apt-get --yes install yarn

cd /opt/

git clone -b $xo_branch $xo_server

cp /opt/xen-orchestra/packages/xo-server/sample.config.yaml /opt/xen-orchestra/packages/xo-server/.xo-server.yaml


# Install n
/usr/bin/curl -o $n_location $n_repo

/bin/chmod +x $n_location

# Symlink node directories
ln -s /usr/bin/node /usr/local/bin/node

# Patch to allow config restore
sed -i 's/< 5/> 0/g' /opt/xen-orchestra/packages/xo-web/src/xo-app/settings/config/index.js

cd $xo_server_dir

/usr/bin/yarn

/usr/bin/yarn build

cd packages/xo-server
cp sample.config.yaml .xo-server.yaml
sed -i "s|#'/': '/path/to/xo-web/dist/'|'/': '/opt/xen-orchestra/packages/xo-web/dist'|" .xo-server.yaml

#Create node_modules directory if doesn't exist
mkdir -p /usr/local/lib/node_modules/

# Symlink all plugins
for source in =$(ls -d /opt/xen-orchestra/packages/xo-server-*); do
    ln -s "$source" /usr/local/lib/node_modules/
done

if [[ ! -e $systemd_service_dir/$xo_service ]] ; then

/bin/cat << EOF >> $systemd_service_dir/$xo_service
# Systemd service for XO-Server.

[Unit]
Description= XO Server
After=network-online.target

[Service]
WorkingDirectory=/opt/xen-orchestra/packages/xo-server/
ExecStart=/usr/local/bin/node ./bin/xo-server
Restart=always
SyslogIdentifier=xo-server

[Install]
WantedBy=multi-user.target
EOF
fi

/bin/systemctl daemon-reload
/bin/systemctl enable $xo_service
/bin/systemctl start $xo_service

echo ""
echo ""
echo "Installation complete, open a browser to:" && hostname -I && echo "" && echo "Default Login:"admin@admin.net" Password:"admin"" && echo "" && echo "Don't forget to change your password!"

