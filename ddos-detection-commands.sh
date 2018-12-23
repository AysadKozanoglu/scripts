Detecting and Mitigating DDOS Attacks

#List all Finish (FIN) packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 1 != 0'


#List all SYN and SYN-ACK packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 2 != 0' 


#List all Reset (RST) packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 4 != 0'


#List all Push (PSH) packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 8 != 0'


#List all acknowledge (ACK) packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 16 != 0'


#List all null packets
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] & 0xff = 0'
OR
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[13] = 0'

#List all packets for your destination port 80 (assuming you are on destination host)
machine1 : sudo /usr/sbin/tcpdump -Nnn -i any -s0 'tcp[2:2] = 80'



#List count of TCP connections by IP address

machine1 : netstat -npt | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      554  X.175.191.23
      5      Y.49.92.30
      3      Z.225.121.76
      2     A.219.69.149
      2     B.152.24.254





#List count of TCP connections by IP address on specific service port

machine1 : netstat -npt | grep <port>  | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      554  X.175.191.23
      5      Y.49.92.30
      3      Z.225.121.76
      2     A.219.69.149
      2     B.152.24.254



#List count of Established TCP connections by IP address  on specific service port and are in ESTABLISHED state

machine1 : netstat -npt | grep <port> | grep ESTABLISHED | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      413  X.175.191.23
      2      Y.49.92.30
      2      Z.225.121.76
      2     A.219.69.149
      2     B.152.24.254

#List count of connections by state
machine1 : netstat -npt | awk '{print $6}' | sort | uniq -c | sort -nr | head
   1749 ESTABLISHED
    118 TIME_WAIT
      6 LAST_ACK
      5 SYN_RECV
      4 FIN_WAIT2
      1 Foreign
      1 FIN_WAIT1
      1 CLOSE_WAIT


SYN flood attacks & mitigations

1)Detect if you are having SYN flood: 
SYN_RECV state it means your server has received the initial SYN packet, it has sent it's own SYN+ACK packet and is waiting on the ACK from the external machine to complete the TCP handshake.

machine1 : netstat -npt | awk '{print $6}' | sort | uniq -c | sort -nr | head
   1749 SYN_RECV
    18 ESTABLISHED
      6 LAST_ACK


Command clearly shows you have lot many connections in SYN_RECV state and possible SYN flood attack.

2)Detect if its from single IP(DOS attack) or multiple IPs(DDOS attack):


Single IP attack:
machine1 : netstat -npt  | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      413  X.175.191.23
      2      Y.49.92.30
      2      Z.225.121.76
      2     A.219.69.149
      2     B.152.24.254


Now you know the culprit IP, you could just block the IP. There are various ways you could block the IP.
Common and quick ways are:
a)Drop packets using ip command: 
machine1: ip route add blackhole X.175.191.23/32

b)Drop packets using iptables command:
iptables -A INPUT -s X.175.191.23 -j DROP

Is ip or iptables command better to use? Hard to say since both works at layer 3/4 of OSI model. You need to check how large is your routing table or iptables. The one to traverse fast should be used.

Multiple IP attack (common subnet):
machine1 : netstat -npt  | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      345  X.175.191.13
      243  X.175.190.27
      34  X.175.181.33
      78  X.175.41.24
      2  Y.42.91.30
      2   Z.125.121.76


Common and quick ways are:
a)Drop subnet using ip command: 
machine1: ip route add blackhole X.175.0.0/16

b)Drop subnet using iptables command:
iptables -A INPUT -s X.175.0.0/16 -j DROP




Its pretty common to have SYN flood attacks from multiple IPs by spoofing source IP address in packets. This way its becomes hard to distinguish sometimes which are real IPs and which are fake.
Multiple IP attack (different subnet):
machine1 : netstat -npt  | grep SYN_RECV | awk '{print $5}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d: -f1 | sort | uniq -c | sort -nr | head
      3  X.175.191.23
      2  Y.42.91.30
      2   Z.125.121.76
      2   A.219.69.149
      2   B.152.24.254
     2   C.142.44.254
     2   D.52.54.214
     1   E.15.27.250



SYN cookies dramatically reduces your CPU and memory usage durin SYN flood attack and helps to keep machine a bit happy.When SYN Cookie is enabled on JUNOS software with enhanced services and becomes the TCP-negotiating proxy for the destination server, it replies to each incoming SYN segment with a SYN/ACK containing an encrypted cookie as its Initial Sequence Number (ISN). The cookie is an MD5 hash of the original source address and port number, destination address and port number, and ISN from the original SYN packet. After sending the cookie, JUNOS software with enhanced services drops the original SYN packet and deletes the calculated cookie from memory. If there is no response to the packet containing the cookie, the attack is noted as an active SYN attack and is effectively stopped.If the initiating host responds with a TCP packet containing the cookie +1 in the TCP ACK field, JUNOS software with enhanced services extracts the cookie, subtracts 1 from the value, and recomputes the cookie to validate that it is a legitimate ACK. If it is legitimate, JUNOS software with enhanced services starts the TCP proxy process by setting up a session and sending a SYN to the server containing the source information from the original SYN. When JUNOS software with enhanced services receives a SYN/ACK from the server, it sends ACKs to the server and to the initiation host. At this point the connection is established and the host and server are able to communicate directly.

Syn Cookies
#Check if SYN cookie is enabled or not:

machine1 : sysctl -a | grep tcp_syncookies
net.ipv4.tcp_syncookies = 0

#Enable it:
machine1 : sysctl -w net.ipv4.tcp_syncookies=1



IPTABLES
#Custom SYN-ATTACK chain
:SYN-ATTACK - [0:0]

#Rule
-A INPUT -i <your interface> -m -p tcp --syn -j SYN-ATTACK
-A SYN-ATTACK -m limit --limit 100/second --limit-burst 100 -j RETURN
-A SYN-ATTACK -m limit --limit 10/h --limit-burst 10 -j LOG --log-prefix "SYN-ATTACK Attack:"
-A SYN-ATTACK -j DROP

