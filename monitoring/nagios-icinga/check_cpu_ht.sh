#!/bin/bash
# author: andreaswendlandt
# desc: simple nagios check for ensuring that hyperthreading is enabled or not
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
core_count=$(dmidecode -t processor | egrep 'Core Count:' | uniq | grep -o '[[:digit:]]*')
thread_count=$(dmidecode -t processor | egrep 'Thread Count:' | uniq | grep -o '[[:digit:]]*')

# check that we don't have empty variables and that the values are integers
if [ -z $core_count ] || [ -z $thread_count ]; then
  echo "WARNING, could not fetch cpu infos"
  exit ${UNKNOWN_STATE}
else
  integer=$(echo $core_count $thread_count | sed 's/[0-9]//g')
  if ! [ -z $integer ]; then
    echo "WARNING, something went wrong, thread count and core count should be integer values but they are not"
    exit ${WARNING_STATE}
  fi
fi

# calculate the result, per default it just checks if hyperthreading
# is enabled and returns an ok, if you run this script with 
# the parameter "off" it gives a warning in case it is enabled

# default
if [ $(($core_count * 2 )) -eq "$thread_count" ]; then 
  result=on
  if [ $# -eq 0 ]; then
    echo "OK, Hyperthreading is enabled"
    exit ${OK_STATE}
  fi
else 
  result=off
  if [ $# -eq 0 ]; then
    echo "CRITICAL, Hyperthreading is disabled"
    exit ${WARNING_STATE}
  fi
fi

# with a parameter
if [ $# -eq 1 ]; then
  if [ "$1" == "off" ]; then
    if [ "$result" == "$1" ]; then
      echo "OK, hyperthreading is disabled and it should be disabled"
      exit ${OK_STATE} 
    elif [ "$result" == "on" ]; then
      echo "WARNING, hyperthreading is enabled but should be disabled"
      exit ${WARNING_STATE}
    else 
      echo "UNKNOWN, could not determine the current status"
      exit ${UNKNOWN_STATE}
    fi
  else
    echo "the parameter $1 is not permitted"
    echo "usage: $0 <off> or $0 <>"
    exit ${WARNING_STATE}
  fi
else 
  echo "this script works with either one parameter or without one, not with $#"
  echo "usage: $0 <param1>"
  exit ${WARNING_STATE}
fi
