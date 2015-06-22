#!/bin/bash
# author: guerillatux
# desc: generates a list of packages that can be updated on the given
# desc: server(s) and sends it via email
# note: this requires the package update-notifier-common installed 
# note: on the target system(s)
# last modified: 27.3.2015

file=/tmp/packages
servers="list_of_your_servers"
mail_to="your_address"

for server in $servers; do
  packages=$(ssh $server "/usr/lib/update-notifier/apt-check -p 2>&1")
  if ! [ -z "$packages"  ]; then
    echo -e "\n $server \n -------------------------- \n $packages" \
    >>$file
  fi
  packages=
done

if [ -s $file ]; then
  cat $file | mail -s "Updates needed on the following Servers" \
  $mail_to
fi

rm $file 2>/dev/null

exit 0
