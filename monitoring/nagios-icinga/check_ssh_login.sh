#!/bin/bash
# author: andreaswendlandt
# desc: simple nagios/icinga plugin to check if a ssh login of a given user is successful on a given server
# last modified: 20240909
# shellcheck disable=SC2034

# nagios/icinga knows 4 exit statuses
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# check that two parameters are passed to the script, a user and a server/host
if [ ${#} -ne 2 ]; then
  echo "error, this check needs  parameter"
  echo "usage: $0 <user> <server>"
  exit ${UNKNOWN_STATE}
fi

user=${1}
server=${2}

# check the ssh login
# note: only ssh logins without password authentication will be checked
if ssh -o ConnectTimeout=3 -o PasswordAuthentication=no -q "${user}"@"${server}" exit >/dev/null 2>&1; then
  echo "OK, user ${user} can login into server ${server}"
  exit ${OK_STATE}
else
  echo "WARNING, user ${user} can not login into server ${server}"
  exit ${WARNING_STATE}
fi
