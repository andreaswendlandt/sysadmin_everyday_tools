#!/bin/bash
# author: andreaswendlandt
# desc: simple nagios/icinga/checkmk check for ensuring that a given service/daemon is running
# last modified: 25.03.2025

# possible exit codes
ok_state=0
critical_state=2
warning_state=1
unknown_state=3

# ensure that a service/daemon is given
if [ $# -ne 1 ]; then
    echo "WARNING, this check needs a service/daemon name to check for"
    echo "usage: $0 <service_name>"
    exit ${warning_state}
fi

# what to check for
daemon=$(systemctl --no-pager list-unit-files | grep -o "\b$1\b.service")

# check the actual state of the given service/daemon in case it is present on the system
if [ "$daemon" == "$1.service" ]; then
    if systemctl status "${1}" 2>/dev/null | grep -E 'is running|active \(running\)' >/dev/null 2>&1; then
        echo "OK, service ${1} is running"
        exit ${ok_state}
    elif systemctl status "${1}"  2>/dev/null | grep -E 'is not running|is stopped|inactive \(dead\)' >/dev/null 2>&1; then
        echo "CRITICAL, service $1 is not running!!!"
        exit ${critical_state}
    else
      echo "UNKNOWN, could not determine the state of $1"
      exit ${unknown_state}
    fi
else
    echo "UNKNOWN, the service ${1} is not present on that system"
    exit ${unknown_state}
fi
