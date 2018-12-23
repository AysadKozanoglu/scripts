#!/bin/bash
# author: Aysad Kozanoglu
#
#  Debian Jessie docker installer
# compiled from https://docs.docker.com/engine/installation/linux/debian/#/debian-jessie-80-64-bit


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

 apt-get update
 apt-get dist-upgrade -y
 apt-get install apt-transport-https ca-certificates -y

 sh -c "echo deb https://apt.dockerproject.org/repo debian-jessie main > /etc/apt/sources.list.d/docker.list"
 apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

 apt-get update
 apt-cache policy docker-engine
 apt-get install docker-engine -y

 service docker start
 docker run hello-world

 group add docker
 groupadd docker
 gpasswd -a $USER docker
service docker restart
