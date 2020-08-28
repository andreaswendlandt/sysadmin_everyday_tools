#!/bin/bash
# author: guerillatux
# desc: check_mk plugin for checking the disk space for a given docker container(jenkins in that case)
# last modified: 27.08.2020

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# Volume ID of the container filesystem
if ! volume_id=$(docker inspect jenkins | grep -i DeviceName | sed -e 's/\(,\|"\)//g'| awk -F- '{print $4}'); then
    echo ${UNKNOWN_STATE} Jenkins_Container_Disk_Usage "Could not find the Volume ID for the jenkins container, please check manually!"
    exit 5
fi

# Disk usage of the above filesystem 
if ! disk_line=$(df | grep $volume_id); then
    echo ${UNKNOWN_STATE} Jenkins_Container_Disk_Usage "Could not get the disk usage for the jenkins container with the volume id $volume_id, please check manually!"
    exit 7
fi

# split the above output into positional parameters
set -- $disk_line

# set the above positional parameters to variables
total_space="$(($2*1024))"
space_used="$(($3*1024))"
percent_used="$5"
int_used=${percent_used%?}

# define the warn- and crit limits
warn_limit=$(echo $total_space | awk '{printf( "%5.f\n", $1*0.8)}')
crit_limit=$(echo $total_space | awk '{printf( "%5.f\n", $1*0.9)}')

# ensure that we have warn- and crit limits
if [ -z "$warn_limit" -o -z "$crit_limit" ]; then
    echo ${UNKNOWN_STATE} Jenkins_Container_Disk_Usage "Could not get calculate the warn- and crit limits, please check manually!"
    exit 9
fi

# give out the result
if [ $int_used -ge 80 ]; then
    if [ $int_used -ge 90 ]; then
        echo ${CRITICAL_STATE} Jenkins_Container_Disk_Usage jenkins_container_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Jenkins container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
    else
        echo ${WARNING_STATE} Jenkins_Container_Disk_Usage jenkins_container_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Jenkins container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
    fi
elif [ $int_used -lt 80 ]; then
        echo ${OK_STATE} Jenkins_Container_Disk_Usage jenkins_container_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Jenkins container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
else
    echo ${UNKNOWN_STATE} Jenkins_Container_Disk_Usage "Could not determine the disk space usage for jenkins, please check manually!"
fi
