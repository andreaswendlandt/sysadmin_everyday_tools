#!/bin/bash
# author: guerillatux
# desc: simple nagios plugin for checking if a reboot is required
# last modified: 13.10.2017

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

if ls -1 /var/run/reboot-required >/dev/null 2>&1; then
    echo "WARNING, a reboot is required on $HOSTNAME"
    exit ${WARNING_STATE}
else
    echo "OK, no reboot is required on $HOSTNAME"
    exit ${OK_STATE}
fi
