#!/bin/bash
# author: awendlandt
# desc: check_mk plugin for checking the disk space from the docker host view for a several containers - taken from a docker compose file
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
    echo ${OK_STATE} Disk_Usage_Container - "Could fetch Container(s) from the compose file"
    for container in $containers_that_should_be_running; do
        if ! volume_id=$(docker inspect $container | grep '"Id":' 2>/dev/null | awk '{print $2}' | sed -e 's/\("\|,\)//g'); then
            echo ${UNKNOWN_STATE} Disk_Usage_Container_${container} "Could not find the Volume ID for the container $container, please check manually!"
        fi
        if ! disk_line=$(df | grep $volume_id); then
            echo ${UNKNOWN_STATE} Disk_Usage_Container_${container} "Could not get the disk usage for the container $container with the volume id $volume_id, please check manually!"
            continue
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
            echo ${UNKNOWN_STATE} Disk_Usage_Container_${container} "Could not calculate the warn- and crit limits, please check manually!"
        fi

        # give out the result
        if [ $int_used -ge 80 ]; then
            if [ $int_used -ge 90 ]; then
                echo ${CRITICAL_STATE} Disk_Usage_Container_${container} ${container}_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Container $container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
            else
                echo ${WARNING_STATE} Disk_Usage_Container_${container} ${container}_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Container $container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
            fi
        elif [ $int_used -lt 80 ]; then
        	echo ${OK_STATE} Disk_Usage_Container_${container} ${container}_disk_usage=$space_used\;${warn_limit}\;${crit_limit} "Container $container disk usage is at "$percent_used"($space_used) out of 100%($total_space)"
        else
            echo ${UNKNOWN_STATE} Disk_Usage_Container_${container} "Could not determine the disk space usage for container $container, please check manually!"
        fi
    done
else
    echo ${UNKNOWN_STATE} Disk_Usage_Container_${container} "Could not fetch any container from the compose file please check manually!"
fi
