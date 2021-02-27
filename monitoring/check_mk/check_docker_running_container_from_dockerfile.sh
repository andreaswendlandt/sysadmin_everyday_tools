#!/bin/bash
# author: awendlandt
# desc: simple check_mk plugin to check if all docker container from a compose file are up
# last modified: 20.2.2021

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# check that the compose file is present
if ! [ -f /var/docker/compose/docker-compose.yml ]; then
    echo ${WARNING_STATE} Docker_Composefile - "Docker composefile is not present"
else
    echo ${OK_STATE} Docker_Composefile - "Docker composefile is present"
fi

# get the names of the container that should be running
containers_that_should_be_running=$(grep hostname /var/docker/compose/docker-compose.yml | grep -v '^#' | awk '{print $2}')

# check each container if he is up (and only if we could retrieve information from the compose file)
if ! [ -z "$containers_that_should_be_running" ]; then
    for container in $containers_that_should_be_running; do
        if docker ps --filter "name=$container" | grep Up >/dev/null; then
            echo ${OK_STATE} Docker_Container_${container} - "Container $container is up and running"
        else
            echo ${CRITICAL_STATE} Docker_Container_${container} - "Container $container is not up and running"
        fi
    done 
else
    echo ${WARNING_STATE} Docker_Composefile - "Could not fetch information from docker composefile"
fi
