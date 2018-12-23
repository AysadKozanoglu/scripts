
# replace 192.168.x.x with your ip 
# apt install mawk

# the server
mawk -W interactive '$0="Aysad: "$0' | nc -l -p 9000 192.168.x.x

# the clients
mawk -W interactive '$0="clientUser1: "$0' | nc 192.168.x.x 9000
