#!/bin/sh

# Author: Aysad Kozanoglu
# clearing nf_tables (netfilter based rules)

command -v iptables >/dev/null 2>&1 || { echo >&2 "iptables not found  Aborting."; exit 1; }

# Accept all traffic first to avoid ssh lockdown  via iptables firewall rules #
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
 
# Flush All Iptables Chains/Firewall rules #
iptables -F
 
# Delete all Iptables Chains #
iptables -X
 
# Flush all counters too #
iptables -Z 
# Flush and delete all nat and  mangle #
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
