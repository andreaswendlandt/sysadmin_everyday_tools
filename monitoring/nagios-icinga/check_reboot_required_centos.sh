#!/bin/bash
# author: andreaswendlandt
# desc: simple nagios plugin for checking if a reboot is required
# last modified: 11.04.2020

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

if ! which needs-restarting >/dev/null 2>&1; then
    echo "Could not find 'needs-restarting', please install manually (yum install yum-utils)"
    exit ${UNKNOWN_STATE}
fi

if ! needs-restarting -r >/dev/null 2>&1; then
    echo "WARNING, a reboot is required on $HOSTNAME"
    exit ${WARNING_STATE}
else
    echo "OK, no reboot is required on $HOSTNAME"
    exit ${OK_STATE}
fi
