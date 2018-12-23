#!/bin/sh
# Author: Aysad Kozanoglu
# quick launch script:
#
# wget -qO reboot.sh https://git.io/fpNpo && chmod a+x reboot.sh ; sh reboot.sh

while true; do
    read -p "Do you wish to reboot server?" yn
    case $yn in
        [Yy]* ) echo "OK, server will boot in 5 sec..."; sleep 4; shutdown -r now; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y for yes or n for no.";;
    esac
done
