#!/bin/bash
# author: guerillatux
# desc: simple nagios check for determinig the expiration date of an imap certificate
# desc: it will give a warning if this is within the next 10 days 
# desc: and a critical within 5 days
# last modified: 21.9.2016

OK_STATE=0 
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

#end date of the certificate
end_date=$(echo | openssl s_client -showcerts -starttls imap -connect imap.yourdomain:143 2>/dev/null| openssl x509 -noout -enddate)
expire_date=${end_date##notAfter=}

#convert value to absolute unix time in seconds
expire_date_absolute=$(date -d "$expire_date" +%s)

#absolut current time in seconds
actual_date=$(date +%s)

#check if no variable is empty
if [ -z "$end_date" -o -z "$expire_date" -o -z "$expire_date_absolute" -o -z "$actual_date" ]; then
  echo "UNKNOWN, something went wrong while calculating, please check manually"
  exit ${UNKNOWN_STATE}
fi

# warning = 10 days, critical, 5 days (in seconds)
warn_value=864000
crit_value=432000

#how many seconds are left 
result=$(($expire_date_absolute - $actual_date))

if [ $result -le $crit_value ]; then
  echo "CRITICAL, the certificate for imap.deutsche-kinemathek.de will expire within the next 5 days ($expire_date)"
  exit ${CRITICAL_STATE}
elif [ $result -gt $crit_value ]; then
  if [ $result -lt $warn_value ]; then
    echo "WARNING, the certificate for imap.deutsche-kinemathek.de will expire within the next 10 days ($expire_date)"
    exit ${WARNING_STATE}
  elif [ $result -gt $warn_value ]; then
    echo "OK, the certificate for imap.deutsche-kinemathek.de will expire on $expire_date"
    exit ${OK_STATE}
  fi
else
  echo "UNKNOWN, could not determine the expiration date of imap.deutsche-kinemathek.de, please check manually"
  exit ${UNKNOWN_STATE}
fi
