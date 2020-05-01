#!/bin/bash
# author: guerillatux
# desc: simple template to use for check_mk plugins
# last modified: 01.05.2020

# 4 possible return values
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3


# perform the check
check_something(){
    "put some fancy logic here"
    "return that"
}
check_something

# generate the result and the output for check_mk
# NOTE: if you don't want to provide performance data replace 'metricname=value' with '-'
if [ check_something ]; then
    echo ${WARNING_STATE} servicename metricname=value "some comment"
elif [ check_something ]; then
    echo ${OK_STATE} servicename metricname=value "some comment"
elif [ check_something ]; then
    echo ${CRITICAL_STATE} servicename metricname=value "some comment"
else
    echo ${UNKNOWN_STATE} servicename - "some comment"
fi
