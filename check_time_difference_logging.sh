#!/bin/bash
# author: guerillatux
# desc: sends a warning if the time difference in logging is bigger
# desc: than 5 minutes
# last modified: 09.06.2015

UNKNOWN_STATE=3
CRITICAL_STATE=2
WARNING_STATE=1
OK_STATE=0

if [ $# -ne 1 ]; then
  echo "error: this script needs one argument"
  echo "usage: $0 Country1|Country2|Country3"
  exit ${UNKNOWN_STATE}
fi

country="$1"

if [ "$country" == "COUNTRY1" -o "$country" == "Country1" -o "$country" == "country1" ]; then
  file_to_check="/var/log/country1-analytics/country1-analytics.nginx.log"
  current_time=$(date -d `date -d "+8 hours" | awk '{print $4}'` +%s)
fi

if [ "$country" == "COUNTRY2" -o "$country" == "Country2" -o "$country" == "country2" ]; then
  file_to_check="/var/log/country2-analytics/country2-analytics.nginx.log"
  current_time=$(date -d `date | awk '{print $4}'` +%s)                                                           
fi

if [ "$country" == "COUNTRY3" -o "$country" == "Country3" -o "$country" == "country3" ]; then
  file_to_check="/var/log/country3-analytics/country3-analytics.nginx.log"
  current_time=$(date -d `date -d "-1 hours" | awk '{print $4}'` +%s)
fi

log_time=$(date -d `tail -n 1 $file_to_check | cut -c 1-16 | awk '{print $3}'` +%s)

# max 5 minutes delay
delay=300

result=$(expr $current_time - $log_time)

if ! [ -n "$result" ] || Result=`echo "$result" | sed 's/[0-9]*//'`; ! [ "$Result" == "" ]; then
  echo "Something went wrong, could not determine the last logging time"
  exit ${UNKNOWN_STATE} 
elif [ $result -ge $delay ]; then
  echo "Warning! Logging in $file_to_check is too old"
  echo "Last logging was $result seconds ago"
  exit ${WARNING_STATE}
else
  echo "Logging is fine"
  echo "Last logging was $result seconds ago"
  exit ${OK_STATE}
fi
