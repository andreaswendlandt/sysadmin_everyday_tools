#!/bin/bash
# author: awendlandt
# desc: check_mk plugin for checking the used docker disk space WITHOUT the thin pool
# last modified: 19.02.2021

# return values
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

docker_data_space_used=$(docker info 2>/dev/null | grep '\bData Space Used' | awk -F\: '{print $2}' | sed -e 's/[[:alpha:]]*\| //g')
docker_thin_pool_available=$(docker info 2>/dev/null | grep '\bThin Pool Minimum Free Space' | awk -F\: '{print $2}' | sed -e 's/[[:alpha:]]*\| //g')
docker_data_space_total=$(docker info 2>/dev/null | grep  '\bData Space Total' | awk -F\: '{print $2}' | sed -e 's/[[:alpha:]]*\| //g')
space_total=$(echo $docker_data_space_total $docker_thin_pool_available | awk '{printf( "%5.f\n", $1-$2)}' | sed -e 's/ //g')

if (( $(echo "$docker_thin_pool_available > 10" | bc -l) )); then
    crit_percent="0.95"
    warn_percent="0.90"
else
    crit_percent="0.90"
    warn_percent="0.80"
fi
    
crit_limit=$(echo $space_total $crit_percent | awk '{printf( "%5.f\n", $1*$2)}' | sed -e 's/ //g')
warn_limit=$(echo $space_total $warn_percent | awk '{printf( "%5.f\n", $1*$2)}' | sed -e 's/ //g')

if (( $(echo "$docker_data_space_used > $warn_limit" | bc -l) )); then
    if (( $(echo "$docker_data_space_used > $crit_limit" | bc -l) )); then
        echo ${CRITICAL_STATE} Docker_Thin_Pool_Space docker_thin_pool_space=$docker_data_space_used\;${warn_limit}\;${crit_limit} "Docker Disk Space used - without the Thin Pool($docker_thin_pool_available GB): $docker_data_space_used GB out of $space_total GB"
    else
        echo ${WARNING_STATE} Docker_Thin_Pool_Space docker_thin_pool_space=$docker_data_space_used\;${warn_limit}\;${crit_limit} "Docker Disk Space used - without the Thin Pool($docker_thin_pool_available GB): $docker_data_space_used GB out of $space_total GB"
    fi
elif (( $(echo "$docker_data_space_used < $warn_limit" | bc -l) )); then
    echo ${OK_STATE} Docker_Thin_Pool_Space docker_thin_pool_space=$docker_data_space_used\;${warn_limit}\;${crit_limit} "Docker Disk Space used - without the Thin Pool($docker_thin_pool_available GB): $docker_data_space_used GB out of $space_total GB"
else
    echo ${UNKNOWN_STATE} Docker_Thin_Pool_Space - "Could not determine the Status of the Thin Pool, please check manually!"
fi
