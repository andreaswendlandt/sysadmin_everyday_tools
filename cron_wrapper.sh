#!/bin/bash
# author: andreaswendlandt
# desc: simple wrapper script for cronjobs which have piped commands
# last modified: 01.07.2018

if [ $# -ne 1 ]; then
    echo "This Script needs 1 Parameter, a Command-Chain"
    echo "Usage: $0 <\"command1|command2|command3\">"
    exit 1
fi

command="$1"

eval "$command; "'pipe=${PIPESTATUS[*]}'
set $pipe

j=1
error=

for i in $*; do
    if [ $i -ne 0 ]; then
        error="$error $j.command"
    fi
    j=$((j+1))
done

if [ -z "$error" ]; then
    echo "$command was successful"
else
    echo "Error at the following Command(s): $error"
fi
