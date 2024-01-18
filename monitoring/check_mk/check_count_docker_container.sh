#!/bin/bash
# author: andreaswendlandt
# desc: simple check_mk plugin to print out the number of running docker container(or a warning if noone is running)
# last modified: 27.08.2020

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# check if the docker command is present on this system
if ! which docker >/dev/null 2>&1; then
    echo ${WARNING_STATE} Docker-Number-Running-Container "can not find docker command, please check manually"
    exit 1
fi

# number of running container
running_container=$(docker ps -a | grep -c Up 2>/dev/null) 

# result and graph
if [ $running_container -eq 0 ]; then
    echo ${WARNING_STATE} Docker-Number-Running-Container running_container=$running_container "Currently no docker container is up" 
else
    echo ${OK_STATE} Docker-Number-Running-Container running_container=$running_container "Currently $running_container docker container are up and running"
fi
