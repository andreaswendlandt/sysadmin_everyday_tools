#!/bin/bash
# author: guerillatux
# desc: simple nagios plugin for checking for long running mysql queries
# last modified: 11.7.2018

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

while getopts "H:u:p:" opt; do
    case $opt in
    H) host="$OPTARG" ;;
    u) user="$OPTARG" ;;
    p) password="$OPTARG" ;;
    esac
done

error=
amount_of_queries=$(mysql -u $user -p$password -h $host -e "show processlist" 2>/dev/null |  grep -v 'show processlist' | tail -n +2 | wc -l)

if [ $amount_of_queries -ge 10 ]; then
    error="$amount_of_queries are running at the Moment"
fi

query_result=
if [ $(mysql -u $user -p$password -h $host -e "show processlist" 2>/dev/null | egrep -v 'show processlist|Waiting for master to send event|Slave has read all relay log' | tail -n +2 | wc -l) -gt 0 ]; then
    while read line; do
        set $line
        if [[ $6 -gt 180 ]]; then
            query_result="$query_result the job with the id $1 is running for $6 minutes "
        fi
    done < <(mysql -u $user -p$password -h $host -e "show processlist" 2>/dev/null)
fi

result=
if ! [ -z "$error" ]; then
    result="Too many Queries running:($amount_of_queries)"
fi

if ! [ -z "$query_result" ]; then
    if [ -z "$result" ]; then
        result="$query_result"
    else
        result="$result and$query_result"
    fi
fi

if ! [ -z "$result" ]; then
    echo  "CRITICAL,$result"
    exit ${CRITICAL_STATE}
else
    echo "OK, no long running Queries and the Amount of Queries are below 10"
    exit ${OK_STATE}
fi 
