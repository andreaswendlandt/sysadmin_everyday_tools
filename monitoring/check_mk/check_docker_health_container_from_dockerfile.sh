#!/bin/bash
# author: awendlandt
# desc: check_mk plugin for checking the "health" values cpu and mem for several containers taken from a compose file
# last modified: 20.02.2021

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# get the names of the container that you want to check the disk space for
containers_that_should_be_running=$(grep hostname /var/docker/compose/docker-compose.yml 2>/dev/null | grep -v '^#' | awk '{print $2}')

# check each container
if ! [ -z "$containers_that_should_be_running" ]; then
    echo ${OK_STATE} Docker_health_status - "Could fetch Container(s) from the compose file"
    for container in $containers_that_should_be_running; do
        if ! health_values=$(docker stats $container --no-stream --format "{{.CPUPerc}}\t{{.MemPerc}}" | tail -n1 |  sed -e 's/%//g'); then
            echo ${UNKNOWN_STATE} Docker_health_status_${container} - "Could not fetch health values for the container $container, please check manually!"
            continue
        fi
        set -- $health_values
        warn=80.00
        crit=90.00
        cpu=$1
        mem=$2
        cpu_result=
        mem_result=
        if (( $(echo "$cpu > $warn" | bc -l) )); then
            if (( $(echo "$cpu > $crit" | bc -l) )); then
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
        if (( $(echo "$mem > $warn" | bc -l) )); then
            if (( $( echo "$mem > $crit" | bc -l) )); then
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
else
    echo ${UNKNOWN_STATE} Docker_health_status - "Could not fetch any container from the compose file please check manually!"
fi
