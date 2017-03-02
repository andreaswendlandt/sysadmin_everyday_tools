#!/bin/bash
# author: guerillatux
# desc: simple nagios check to determine if the given pool is out of tapes
# last modified: 01.03.2017

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

pool_to_check=$1

if [ $# -ne 1 ]; then
  echo "WARNING, this script needs a pool name to check for"
  echo "usage: $0 'pool_name'"
  exit ${WARNING_STATE}
fi

all_pools=$(echo "list pools" | bconsole | awk '{print $4}' | sed -n '10,$p' | grep -v '^$')
if ! echo $all_pools | grep -w $pool_to_check >/dev/null; then
    echo "WARNING, the specified pool does not exist on this bacula instance"
    exit ${WARNING_STATE}
fi

result=$(echo "list volumes pool=$pool_to_check" | bconsole | grep -c '[[:digit:]]*L6')

if ! echo "$result" | egrep '^[[:digit:]]+$' >/dev/null 2>&1; then
    echo "UNKNOWN, could not determine the number of tapes in pool $pool_to_check please check manually"
    exit ${UNKNOWN_STATE}
fi

if [ $result -ge 5 ]; then
    echo "OK, there are $result tapes in pool $pool_to_check"
    exit ${OK_STATE}
elif  [ $result -le 5 ]; then
    if [ $result -le 2 ]; then
        if [ $result -eq 0 ]; then
            echo "CRITICAL, pool $pool_to_check is empty!!!"
            exit ${CRITICAL_STATE}
        else
            echo "CRITICAL, there are only $result tapes left in pool $pool_to_check"
            exit ${CRITICAL_STATE}
        fi
    else
        echo "WARNING, only $result tapes left in pool $pool_to_check"
        exit ${WARNING_STATE}
    fi
else
    echo "UNKNOWN, could not determine the number of tapes in pool $pool_to_check please check manually"
    exit ${UNKNOWN_STATE}
fi
