#! /bin/sh
# author: Aysad Kozanoglu
# email: aysadx@gmail.com
# Debian Jessie
# QUICK USAGE: 
#     wget -O - "https://git.io/fAtyh" | bash




watch "netstat -atun | grep -v -E  'address|and|Recv-Q' | awk '{print $5}' | cut -d: -f1 | sed -e '/^$/d' |sort | uniq -c | sort -r"
