#!/bin/bash
# author: andreaswendlandt
# desc: simple ufw based firewall
# last modified: 08.03.2016

# define our network class
network_class=$(ifconfig -a | grep '\' | head -n1 | awk '{print $2}' \
| egrep -o '([0-9]{1,3}\.){3}.[0-9]{1,3}' | awk -F \. '{print $1}')

# our ip address
ip_address=$(ifconfig -a | grep '\' | head -n1 | awk '{print $2}' \
| egrep -o '([0-9]{1,3}\.){3}.[0-9]{1,3}')

network=

if [ $network_class == 192 ]; then
  network="192.168.0.0/16"
elif [ $network_class == 172 ]; then
  network="172.16.0.0/12"
elif [ $network_class == 10 ]; then
  network="10.0.0.0/8"
else
  echo "could not determine our network, aborting"
  exit 1
fi

# enable logging
ufw logging on

# start ufw
ufw enable

## TCP

tcp_ports="list_of_ports"
for port in $tcp_ports; do
  ufw allow proto tcp from $network to $ip_address port $port
done

## UDP

udp_ports="list of ports"
for port in $udp_ports; do
  ufw allow proto udp from $network to $ip_address port $port
done
