#!/bin/bash
# author: andreaswendlandt
# desc: simple iptables based firewall for ipv4 and ipv6, udp and tcp
# last modified: 07.03.2016

# ensure that it works for both, ipv4 and ipv6

IPT () {
  iptables $@
  ip6tables $@
}

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

tcp_ports="list_of_ports"
for tcp_port in $tcp_ports; do
  IPT -A INPUT -p tcp --dport $tcp_port -j ACCEPT
done

## UDP

udp_ports="list_of_ports"
for udp_port in $udp_ports; do
  IPT -A INPUT -p udp --dport $udp_port -j ACCEPT
done
