#!/bin/bash
# author: guerillatux
# desc: simple nagios check to determine if the recycling flag is set in bacula on a specific pool
# last modified: 01.02.2017

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

result=$(echo "list volume pool=your-pool" | bconsole | awk -F\| '$9 ~ "1" { print $2 }')
if [ $? -ne 0 ]; then
    echo "something went wrong with connecting to bacula, please check manually"
    exit ${UNKNOWN_STATE}
fi

if [ -z "$result" ]; then
    echo "OK, the recycling bit is not set to '1' on any media in your-pool"
    exit ${OK_STATE}
else
    echo -n "CRITICAL, on these medias "$result" the recycling bit is set to '1', fix it please"
    exit ${CRITICAL_STATE}
fi
