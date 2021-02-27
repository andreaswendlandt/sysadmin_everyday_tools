#!/bin/bash
# author: awendlandt
# desc: simple check_mk plugin to check if all given docker container are up and running
# last modified: 19.02.2021

# return values
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# names of the containers that you want to check
containers_that_should_be_running="container1 container2"

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
