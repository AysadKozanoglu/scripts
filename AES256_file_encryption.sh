#!/bin/bash
#####################################################
# Author: Aysad Kozanoglu
#
# OS: Debian / Ubuntu / all derivates of Debian 
#
# Usage: file_encrypter.sh enc|dec FILENAME
#
#####################################################

if $(which openssl> /dev/null); 
  then 
     echo "openssl found, OK..."; 
else 
   sudo apt-install -y -q openssl; 
fi

if [ -z "$2" ] || [ -z "$1" ];
 then
        echo "error "; exit 1;
fi 

if [ $1 == "enc" ];
 then
        openssl aes-256-cbc -a -salt -in $2 -out ${2}.enc
        rm -i ${2}
        exit 0
fi

if [ $1 == "dec" ];
 then
        openssl aes-256-cbc -d -a -in ${2}.enc -out $2
        exit 0
fi
