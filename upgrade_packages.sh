#!/bin/bash
# author: guerillatux
# desc: update packages on one or more servers
# last modified: 27.3.2015

if [ $# -ne 1 ]; then
  echo "error, this script needs one argument, either a hostname\ 
or a list of hostnames"
  echo "usage: $0 servername or $0 \"list_of_servers\""
  exit 1
fi

servers="$1"

# logfile
logfile="/tmp/update-$(date +%Y-%m-%d).log"

# only store logfiles for one week
find /tmp -type f -name 'update-*.log' -mtime +6 -exec rm {} \;

function packagelist() {
  # define a blacklist of packages you don't want to update example: package_blacklist="package1|package2|package3"
  package_blacklist=""
  if [ "$package_blacklist" == "" ]; then
    packages=$(/usr/lib/update-notifier/apt-check -p 2>&1 | xargs -n 1 echo apt-get -y install | awk '{print $4}')
  else
    packages=$(/usr/lib/update-notifier/apt-check -p 2>&1 | egrep -v "$package_blacklist" | xargs -n 1 echo apt-get -y install | awk '{print $4}')
  fi
  if [ "$packages" ]; then
    echo -e "$HOSTNAME \n \n$packages will be updated on $HOSTNAME"
    for package in  $packages; do
      echo "$package will be updated now"
      sudo apt-get -y install $package > /dev/null
      # check if anything went wrong with the update 
      dpkg -l | grep $package | grep '^ii' >/dev/null && echo "$package successfully updated on $HOSTNAME" || echo "something went wrong updating $package on $HOSTNAME"
      # check if in case the updated package was a daemon that this daemon is running afterwards
      if ls -1 /etc/init.d | grep '\b$package\b'; then
        /etc/init.d/$package status | grep 'is running' && echo "service $package is running" || echo "service $package is not running"
      fi
    done
  else
    echo "nothing to update on $HOSTNAME"
  fi
}

for host in $servers; do
  ssh $host "$(declare -f packagelist); packagelist
  echo"
done  | tee -a $logfile

exit 0

