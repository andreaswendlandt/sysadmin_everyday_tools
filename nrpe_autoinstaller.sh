#!/bin/bash
# author: guerillatux
# desc: autoinstaller for nagios nrpe server with integration to 
# desc: an existing nagios instance
# last modified: 04.03.2016

# ip address of this system
ip_address=$(ifconfig -a | grep '\' | head -n1 | awk '{print $2}' | egrep -o '([0-9]{1,3}\.){3}.[0-9]{1,3}')

# check if we are root
if ! [ $(whoami) == "root" ]; then 
  echo "that script needs superuser permissions"
  exit 1
fi

# check if we have an internet connection
 if ! ping -c3 google.de >/dev/null 2>&1; then
  echo "no internet connection, can not install packages"
  exit 1
fi

# install all required packages and ask for the ip of the nagios server
echo "installing the nagios nrpe server..."
apt-get update >/dev/null 2>&1 && apt-get -y install nagios-nrpe-server nagios-plugins nagios-plugins-basic nagios-plugins-standard >/dev/null 2>&1

if [ $? == 0 ]; then
  echo "...nagios nrpe server installed"
  read -p  "please type in the ip address of your nagios server: " address
  # check if it is a valid ipv4 address...
    if echo $address | egrep '([0-9]{1,3}\.){3}.[0-9]{1,3}' >/dev/null; then
      # ...and append it to the config file
      sed -i "s/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, $address/" /etc/nagios/nrpe.cfg
    else
      echo "your input is not a valid ip address"
      exit 1
    fi
else
  echo "could not install the nagios nrpe server"
  exit 1
fi

echo "configuration file amended"

# restart the nrpe server and reload the config
echo "reload configuration"
service nagios-nrpe-server stop >/dev/null
sleep 2 
service nagios-nrpe-server start >/dev/null

# finally if the server is running print out the ip address of
# the system for creating a host file on the nagios server
if service nagios-nrpe-server status | grep 'is running' >/dev/null; then
  echo "your nagios nrpe server is running and your ip address is: "
  echo "$ip_address, create a host file on your nagios server and "
  echo "your server will be monitored."
else
  echo "could not start the nagios nrpe server"
exit 1
fi
