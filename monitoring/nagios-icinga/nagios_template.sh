#!/bin/bash
# author: andreaswendlandt
# desc: simple template to use for nagios checks
# last modified: 24.5.2015

# nagios knows 4 exit status
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# first, check the amount of parameter in case you need them,
# otherwise outcomment this section
if [ $# -ne 3 ]; then
  echo "error, this check needs 3 parameter"
  echo "usage: $0 param1 param2 param3"
  exit ${UNKNOWN_STATE}
fi

# perform the regular check
if [ check something ]; then
  echo "some comment"
  exit ${WARNING_STATE}
elif [ check something ]; then
  echo "some comment"
  exit ${OK_STATE}
elif [ check something ]; then
  echo "some comment"
  exit ${CRITICAL_STATE}
else
  echo "could not determine the status"
  exit ${UNKNOWN_STATE}
fi
