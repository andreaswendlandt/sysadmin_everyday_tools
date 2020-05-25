#!/bin/bash
# author: guerillatux
# desc: simple check_mk plugin for evaluating the license usage based on values of a splunk logfile
# desc: it will return a warning if the usage is above 80% and a critical if the usage is above 90%
# desc: a graph will be generated as well
# last modified: 22.05.2020

# 4 possible return values
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# current date
current_date=$(date +%m-%d-%Y)

if grep $current_date /tmp/splunk.log >/dev/null 2>&1; then
    license_limit=$(grep $current_date /tmp/splunk.log | grep -o 'poolsz=[0-9]*' | awk -F\= '{print $2}')
    license_usage=$(grep $current_date /tmp/splunk.log | grep -o 'b=[0-9]*' | awk -F\= '{print $2}')
    # warning limit 80%
    warn_limit=$(echo $license_limit | awk '{printf( "%5.f\n", $1*0.8)}')
    # critical limit 90%
    crit_limit=$(echo $license_limit | awk '{printf( "%5.f\n", $1*0.9)}')
    if ! [ -z "$license_limit" -o -z "$license_usage" -o -z "$warn_limit" -o -z "$crit_limit" ]; then
        if [[ $license_usage -gt $warn_limit ]]; then
            if [[ $license_usage -gt $crit_limit ]]; then
                echo ${CRITICAL_STATE} splunk_log_license license_evaluation=$license_usage\;$warn_limit\;$crit_limit "log license usage is over 90% ($license_usage) out of $license_limit"
            else
                echo ${WARNING_STATE} splunk_log_license license_evaluation=$license_usage\;$warn_limit\;$crit_limit "log license usage is over 80% ($license_usage) out of $license_limit"
            fi
        else
            echo ${OK_STATE} splunk_log_license license_evaluation=$license_usage\;$warn_limit\;$crit_limit "log license usage is below 80% ($license_usage) out of $license_limit"
        fi
    else
        echo ${UNKNOWN_STATE} splunk_log_license - "can not collect/calculate all the required values from the logfile - please check manually!"
    fi
else
    echo ${UNKNOWN_STATE} splunk_log_license - "can not find the current date in the logfile - please check manually!"
fi
