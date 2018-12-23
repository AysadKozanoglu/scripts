#! /bin/sh
# author: Aysad kozanoglu
#
# quick launch script:
#
# wget -O - https://git.io/fpbwk | sh

export LC_ALL=en_US.UTF-8

export LANG=en_US.UTF-8

export LANGUAGE=en_US.UTF-8

echo "export LC_ALL=en_US.UTF-8" >> /etc/bash.bashrc

echo "export LANG=en_US.UTF-8"  >> /etc/bash.bashrc

echo "export LANGUAGE=en_US.UTF-8"  >> /etc/bash.bashrc

locale-gen en_US.UTF-8

echo "LANG=en_US.UTF-8" > /etc/default/locale
