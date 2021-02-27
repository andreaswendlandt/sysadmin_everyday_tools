#!/bin/bash
# author: awendlandt
# desc: check_mk plugin for checking the "health" values cpu and mem from several containers
# last modified: 19.02.2021

# return values
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# special limits for a special container(special in terms of it has a higher cpu utilization)
cpu_percentage=$(($(grep -c processor /proc/cpuinfo)*100))
cpu_warn_limit_special_container="$(echo $cpu_percentage | awk '{printf( "%5.f\n", $1*0.8)}').00"
cpu_crit_limit_special_container="$(echo $cpu_percentage | awk '{printf( "%5.f\n", $1*0.9)}').00"

# names of the containers that you want to check
containers_that_should_be_running="container1 container2 container3 container4"

# check each container
for container in $containers_that_should_be_running; do
    if ! health_values=$(docker stats $container --no-stream --format "{{.CPUPerc}}\t{{.MemPerc}}" | tail -n1 |  sed -e 's/%//g'); then
        echo ${UNKNOWN_STATE} Docker_health_status_${container} - "Could not fetch health values for the container $container, please check manually!"
        continue
    fi
    set -- $health_values
    mem_warn=80.00
    mem_crit=90.00
    if echo $container | grep special_container >/dev/null; then
        cpu_warn=$cpu_warn_limit_special_container
	cpu_crit=$cpu_crit_limit_special_container
    else
        cpu_warn=80.00
        cpu_crit=90.00
    fi
    cpu=$1
    mem=$2
    cpu_result=
    mem_result=
    if (( $(echo "$cpu > $cpu_warn" | bc -l) )); then
        if (( $(echo "$cpu > $cpu_crit" | bc -l) )); then
            cpu_int=2
            cpu_result="cpu utilization is at ${cpu}%"
        else
            cpu_int=1
            cpu_result="cpu utilization is at ${cpu}%"
        fi
    else
        cpu_int=0
        cpu_result="cpu utilization is at ${cpu}%"
    fi
    if (( $(echo "$mem > $mem_warn" | bc -l) )); then
        if (( $( echo "$mem > $mem_crit" | bc -l) )); then
            mem_int=2
            mem_result="mem utilization is at ${mem}%"
        else
            mem_int=1
            mem_result="mem utilization is at ${mem}%"
        fi
    else
        mem_int=0
        mem_result="mem utilization is at ${mem}%"
    fi
    if [ $cpu_int == "0" ] && [ $mem_int == "0" ]; then
        echo ${OK_STATE} Docker_health_status_${container} - "$cpu_result  $mem_result"
    elif [ $cpu_int == "2" ] || [ $mem_int == "2" ]; then
        echo ${CRITICAL_STATE} Docker_health_status_${container} - "$cpu_result  $mem_result"
    elif [ $cpu_int == "1" ] || [ $mem_int == "1" ]; then
        echo ${WARNING_STATE} Docker_health_status_${container} - "$cpu_result  $mem_result"
    else
        echo ${UNKNOWN_STATE} Docker_health_status_${container} - "Could not calculate the health values for the container $container, please check manually!"
    fi
done
