#!/bin/bash
# author: guerillatux
# desc: simple nagios check for ensuring that a given service/daemon is running
# last modified: 13.07.2016

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

if [ $# -ne 1 ]; then
    echo "WARNING, this check needs a service/daemon name to check for"
    echo "usage: $0 <service_name>"
    exit ${WARNING_STATE}
fi

daemon=$(ls -1 /etc/init.d/ | grep $1)

if [ "$daemon" == "$1" ]; then
    if /etc/init.d/$1 status 2>/dev/null | grep "is running" >/dev/null 2>&1; then
        echo "OK, service $1 is running"
        exit ${OK_STATE}
    elif /etc/init.d/$1 status 2>/dev/null | grep "is not running" >/dev/null 2>&1; then
        echo "CRITICAL, service $1 is not running!!!"
        exit ${CRITICAL_STATE}
    else
      echo "UNKNOWN, could not determine the state of $1"
      exit ${UNKNOWN_STATE}
    fi
else
    echo "UNKNOWN, the service $1 is not present on that system"
    exit ${UNKNOWN_STATE}
fi
