#!/bin/bash
# author: guerillatux
# desc: simple nagios check for checking expiring ssl certificates
# last modified: 10.09.2015

OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

if [  $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "this check needs 2 or 3 parameters"
  echo "the last one is optional as it is the critical state"
  echo "usage: $0   (optional)"
  exit 3
fi

domain_to_check=$1
expiring_date=$(echo | openssl s_client -connect $domain_to_check \
2>/dev/null | openssl x509 -noout -dates | tail -1 | sed -e \
's/notAfter=//' | awk '{print $1"-"$2"-"$4}')
expiring_int=$(date -d "$expiring_date" +%s)
now_int=$(date +%s)
warning=$2
warning_int=$(expr $2 \* 86400)

if [ $# -eq 3 ]; then
  critical=$3
  critical_int=$(expr $3 \* 86400)
  echo $critical_int
fi

result_int=$(expr $expiring_int - $now_int)
result_days=$(expr $result_int / 86400)

if [ $result_int -ge $warning_int ]; then
  echo "OK, the certificate expires in $result_days days"
  exit ${OK_STATE}
fi
if [ $# -eq 3 ]; then
  if [ $result_int -le $critical_int ]; then
    echo "CRITICAL, the certificate expires in $result_days days"
    exit ${CRITICAL_STATE}
  fi
fi
if [ $result_int -le $warning_int ]; then
  echo "WARNING, the certificate expires in $result_days days"
  exit ${WARNING_STATE}
fi
