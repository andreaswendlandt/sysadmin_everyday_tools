#!/bin/bash
# author: andreaswendlandt
# desc: simple nagios check for determining the temperatur of a room,
# desc: measured by an allnet all3418v2 device
# last modified: 02.12.2015

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

warning=$1
critical=$2

if [ $# -ne 2 ]; then
  echo "WARNING, this script needs 2 arguments"
  echo "usage: $0  "
  exit ${WARNING_STATE}
fi

result=$(curl -s http://your_ip/xml/?mode=sensor\&type=list\&id=102 | tail -1| sed -e 's/.*\(.*\)<\/current>.*/\1/')

if [ -z "$result" ]; then
  echo "UNKNOWN, could not determine the temperature"
  exit ${UNKNOWN_STATE}
fi

if [ $(echo "if (${result} > ${warning}) 1 else 0" | bc) -eq 1 ]; then 
  if [ $(echo "if (${result} > ${critical}) 1 else 0" | bc) -eq 1 ]; then
    echo "CRITICAL, the temperature is $result °C"
    exit ${CRITICAL_STATE}
  else
    echo "WARNING, the temperature is $result °C"
    exit ${WARNING_STATE}
  fi
else
  echo "OK, the temperature is $result °C"
  exit ${OK_STATE}
fi
