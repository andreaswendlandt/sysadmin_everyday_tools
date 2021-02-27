#!/bin/bash 
# author: awendlandt
# desc: check to evaluate the expiration of certificate(s) 
# last modified: 18.02.2021 

# return values 
OK_STATE=0 
CRITICAL_STATE=2 
WARNING_STATE=1 
UNKNOWN_STATE=3 

is_int(){
    if [ -z "$(echo "$1" | sed -e 's/[[:digit:]]//g')" ]; then
        return 0
    else
        return 1
    fi
}

instances="url_1 url_2 url_3" 

for instance in $instances; do 
    expirationdate=$(date -d "$(echo | openssl s_client -connect ${instance}:443 -servername $instance 2>/dev/null | openssl x509 -text | grep 'Not After' |awk '{print $4,$5,$7}')" '+%s') 
    now=$(date +%s) 
    days_until_expiration=$(($((expirationdate - now)) / 86400)) 
    if is_int $days_until_expiration; then
        if [ $days_until_expiration -le 30 ]; then 
            if [ $days_until_expiration -le 10 ]; then 
                echo ${CRITICAL_STATE} Certificate_expiration_$instance - "Certificate for $instance will expire in $days_until_expiration days" 
            else 
                echo ${WARNING_STATE} Certificate_expiration_$instance - "Certificate for $instance will expire in $days_until_expiration days" 
            fi 
        elif [ $days_until_expiration -gt 30 ]; then 
            echo ${OK_STATE} Certificate_expiration_$instance - "Certificate for $instance will expire in $days_until_expiration days" 
        else 
            echo ${UNKNOWN_STATE} Certificate_expiration_$instance - "Could not calculate the expiration date for $instance" 
        fi 
    else
        echo ${UNKNOWN_STATE} Certificate_expiration_$instance - "Could not determine the expiration date for $instance" 
    fi
done
