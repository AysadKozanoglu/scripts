nbtscan 192.168.1.0-192.168.1.255

detail info host
nmap -A 192.168.1.8

get most ports
nmap --script smb-os-discovery 192.168.1.8

get mac adress ips hostnames
nmap -sP 192.168.1.0/24 | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print " => "$3;}' | sort

get hostname alives
nmap -sn 192.168.1.0/24 | awk '/Nmap scan report for/{printf $5"\n"}'

host und mac in form ip/mac
tmp=$(mktemp) && nmap -sP 192.168.1.0/24 | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print "/"$3;}' > $tmp && cat $tmp | while read line; do echo $line; done;

nur host
cat $tmp |  cut -d\/ -f1 | while read line; do echo $line; done;

ssh 192.168.1.8 df -h | grep root | grep -v Filesystem | awk '{printf $1" "$2 " "$4"\n"}'


 nmap -sP 192.168.1.* | grep report | awk '{printf $5"\n"}' | while read line; do nmap --open $line; done;

nur os details,open port,mac address
nmap -min-parallelism 100 -sn 192.168.1.1 | grep report | awk '{printf $5"\n"}' | while read line; do nmap -O -vv $line | grep -E "OS details|open port|Max Address"; done;

check ssh
ssh -q -t -t 192.168.1.8 "echo SUCCESS;" || echo "FAIL"

get all hosts
sudo  nmap -sn 192.168.1.0/24 | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print "/"$3;}' | cut -d\/ -f1 | while read line; do echo $line;done;

check ssh
e=$(nmap --open 192.168.1.8 | grep ssh | wc -l) && if [ $e -ne 0 ]; then  echo "OK"; fi;

sudo  nmap -min-parallelism 100 -sn 192.168.1.0/24 | awk '/Nmap scan report for/{printf $5;}/MAC Address:/{print "/"$3;}' | cut -d\/ -f1 | while read line; do e=$(nmap --open $line | grep ssh | wc -l) && if [ $e -ne 0 ]; then  echo "$line OK";fi;done;

not reachable targets 	
fping -g 192.168.1.0/24 -s -q  -u

fping 192.168.1.1 | awk '{printf $1}
