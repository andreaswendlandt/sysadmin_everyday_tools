#!/bin/bash
# author: guerillatux
# desc: quick and dirty solution to overwrite /etc/resolv.conf with your own nameserver(s)
# last modified: 27.04.2016

# to be able to edit /etc/resolv.conf we must be root
if ! [ $(whoami) = "root" ]; then
  echo "this script needs to be run with root privileges"
  exit 1
fi

# as there is always one nameserver entry (mostly localhost) we want to insert our nameserver
# before that entry
sed -i '/nameserver/i nameserver <ip_address> \nnameserver <ip_address>' /etc/resolv.conf
