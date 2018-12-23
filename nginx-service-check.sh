#!/bin/sh
# Author: Aysad Kozanoglu

 SERVICE='nginx'
    DATE=$(date '+%Y-%m-%d %H:%M:%S')
NGINXBIN=$(which nginx)
   LOGTO=/var/log/serviceChecker.log

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    echo "$DATE $SERVICE service running, everything is fine" >> $LOGTO
else
    echo "$DATE $SERVICE service is not running... starting now " >> $LOGTO
    $NGINXBIN
fi
