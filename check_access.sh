#!/bin/bash
# author: guerillatux
# desc: script to check for deployment purposes that a bunch of
# desc: servers can reach a deployment server on a given port
# last modified: 3.4.2015

servers="list_of_your_servers"
deployment_server="your_deployment_server"
port="port_of_the_deployment_server"
mail_to="your_mail_address"
file="/tmp/deployment"

for host in $servers; do
  if ! ssh $host "curl -s --retry 1 $deployment_server:$port 2>&1 >/dev/null"
    then echo -e "$host \n" >> $file
  fi
done

if [ -s "$file" ]; then
  cat $file | mail -s  "These Servers cannot access $deployment_server:" $mail_to
fi

rm $file 2>/dev/null

exit 0
