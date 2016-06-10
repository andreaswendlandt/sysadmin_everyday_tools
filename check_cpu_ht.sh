#!/bin/bash
# author: guerillatux
# desc: simple nagios check for ensuring that hyperthreading is enabled
# last modified: 10.06.2016

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# check if we are root
if ! [ $(whoami) == "root" ]; then 
  echo "WARNING, that script needs superuser permissions"
  exit ${WARNING_STATE}
fi

# check if dmidecode is available on the system
if ! which dmidecode >/dev/null; then
  echo "WARNING, this check needs dmidecode and it is not present"
  exit ${WARNING_STATE}
fi

# ensure that hyperthreading is available
if ! dmidecode -t processor | grep -i htt >/dev/null; then
  echo "WARNING, hyperthreading is not available on this system"
  exit ${WARNING_STATE}
fi

# fetch the values we need
core_count=$(dmidecode -t processor | egrep 'Core Count:' | grep -o '[[:digit:]]')
thread_count=$(dmidecode -t processor | egrep 'Thread Count:' | grep -o '[[:digit:]]')

# check that we don't have empty variables and that the values are integers
if [ -z $core_count ] || [ -z $thread_count ]; then
  echo "WARNING, could not fetch cpu infos"
  exit ${UNKNOWN_STATE}
else
  integer=$(echo $core_count $thread_count |sed 's/[0-9]//g')
  if ! [ -z $integer ]; then
    echo "WARNING, something went wrong, thread count and core count should be integer values and they are not"
    exit ${WARNING_STATE}
  fi
fi

# calculate the result 
if [ $(($core_count * 2 )) -eq "$thread_count" ]; then 
  echo "OK, Hyperthreading is enabled"
  exit ${OK_STATE}
else 
  echo "CRITICAL, Hyperthreading is disabled"
  exit ${CRITICAL_STATE}
fi
