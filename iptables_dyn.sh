#!/bin/bash
# author: guerillatux
# desc: simple iptables based firewall for ipv4 and ipv6, udp and tcp
# last modified: 07.03.2016

# ensure that it works for both, ipv4 and ipv6

IPT () {
  iptables $@
  ip6tables $@
}

tcp_ports=$(cat /path_to_your_file >/dev/null 2>&1)
udp_ports=$(cat /path_to_your_file >/dev/null 2>&1)

if [ "$tcp_ports" == "" -a "$udp_ports" == "" ]; then
  echo "warning, neither tcp nor udp ports are specified, aborting"
  exit 1
fi

# remove everything and start from scratch

IPT -F INPUT
IPT -F OUTPUT
IPT -F FORWARD

# deny everything as a default policy

IPT -P INPUT DROP
IPT -P FORWARD DROP
IPT -P OUTPUT DROP

# allow traffic initialized from ourselves

IPT -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
IPT -A INPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# start to enable stuff, in particular loopback interface

IPT -t filter -A INPUT -i lo -j ACCEPT
IPT -t filter -A OUTPUT -i lo -j ACCEPT

# allow icmp from all private networks

IPT -I INPUT -p icmp -s 192.168.0.0/16 -j ACCEPT
IPT -I INPUT -p icmp -s 172.16.0.0/12 -j ACCEPT
IPT -I INPUT -p icmp -s 10.0.0.0/8 -j ACCEPT

## TCP

for tcp_port in $tcp_ports; do
  IPT -A INPUT -p tcp --dport $tcp_port -j ACCEPT
done

## UDP

for udp_port in $udp_ports; do
  IPT -A INPUT -p udp --dport $udp_port -j ACCEPT
done
