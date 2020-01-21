#!/bin/sh

# Author: Aysad Kozanoglu
#  email: aysadx@gmail.com
#    web: aysad.pe.hu


cp /etc/sysctl.conf /etc/sysctl.conf.ori

wget -qO /etc/sysctl.conf "https://git.io/fAtS7"

echo -e " set sysconf tuning \n"

sysctl -p /etc/sysctl.conf

echo -e "sysconf tuning finished"
