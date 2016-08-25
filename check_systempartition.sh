#!/bin/bash
# author: guerillatux
# desc: simple nagios check for measuring the used space of /
# last modified: 24.08.2016
                                                                                                                                                                                                                                                    OK_STATE=0 
CRITICAL_STATE=2                                                                                                                                                                                                                                    
WARNING_STATE=1                                                                                                                                                                                                                                
UNKNOWN_STATE=3
warn_value=80
crit_value=90

result=$(df -h | grep '/$' | head -n1 | awk '{print $5}' | grep -o '[0-9]*')
set -- $(df -h | grep '/$' | head -n1)

if [ $# -ne 6 -o -z "$result" ]; then
  echo "something went wron while calculating the space, check manually"
  exit ${UNKNOWN_STATE}
fi

if [ $result -le $warn_value ]; then
  echo "DISK OK - free space:/ $4, used $3 of $2 (${result}%)"
  exit ${OK_STATE}
elif [ $result -ge $crit_value ]; then
  echo "DISK CRITICAL - free space:/ $4, used $3 of $2 (${result}%)"
  exit ${CRITICAL_STATE}
elif [ $result -ge $warn_value ]; then
  echo "DISK WARNING - free space:/ $4, used $3 of $2 (${result}%)"
  exit ${WARNING_STATE}
else
  echo "could not determine the status of the systempartition, check manually"
  exit ${UNKNOWN_STATE}
fi
