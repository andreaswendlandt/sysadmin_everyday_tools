#!/bin/bash
# author: andreaswendlandt
# desc: check_mk plugin for evaluating the validity of java keystore certificates
# desc: certificates with less or equal 30 days will return a warning, everything above will return ok
# last modified: 30.05.2020

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

#dependencies (keytool)
if ! which keytool >/dev/null 2>&1; then
    echo ${UNKNOWN_STATE} certificate_keystore_validity - "Could not find 'keytool', please install manually"
    exit ${UNKNOWN_STATE}
fi

# date of today and the result evaluating variables
today=$(date +%s)
ok=
warn=

# function for checking if a variable is an integer one
is_int(){
    if [ -z "$(echo "$1" | sed -e 's/[[:digit:]]//g')" ]; then
        return 0
    else
        return 1
    fi
}

# function for checking if a variable is empty
is_empty(){
    if [ -z "$1" ]; then
        return 0
    else
        return 1
    fi
}

# calculating and evaluating the result(s) 
## replace 'path_to_your_stores', 'your_filename' and 'your_keystore' with your values
if ls /path_to_your_stores/* >/dev/null 2>&1; then
    for store in $(ls -1 /path_to_your_stores/); do
        pass=$(grep crypto /path_to_your_stores/${store}/conf/your_filename.properties | awk -F\= '{print $2}')
        # removing carriage return from the variable
        password="${pass%%[[:cntrl:]]}"
        if is_empty "$password"; then
            echo ${UNKNOWN_STATE} certificate_keystore_validity - "could not extract the password for $store, please check manually"
            exit ${UNKNOWN_STATE}
        fi
        valid_until=$(keytool -list -v -storepass "$password" -keystore /path_to_your_store/${store}/users/*/your_keystore.jks | egrep -i 'gültig|until' | head -1 | awk -F'bis:|until:' '{print $2}')
        if is_empty "$valid_until"; then
            echo ${UNKNOWN_STATE} certificate_keystore_validity - "could not extract the 'valid until' value for $store, please check manually"
            exit ${UNKNOWN_STATE}
        fi
        expire=$(date -d "$valid_until" +%s)
        if is_int "$expire" -a is_int "$today"; then
            valid_days=$((($expire-$today)/86400))
        else
           echo ${UNKNOWN_STATE} certificate_keystore_validity - "something went wrong with the variable handling, please check manually"
           exit ${UNKNOWN_STATE}
        fi
        if is_int "$valid_days"; then
            if [ "$valid_days" -gt 30 ]; then
                ok="$ok $store is valid for $valid_days days."
            elif [ "$valid_days" -le 30 ]; then
                warn="$warn $store is only for $valid_days valid days."
            else
                echo ${UNKNOWN_STATE} certificate_keystore_validity - "could not determine the status of $store, please check manually"
                exit ${UNKNOWN_STATE}
            fi
        fi
    done
else
    echo ${UNKNOWN_STATE} certificate_keystore_validity - "no keystore folder found, please check manually"
    exit ${UNKNOWN_STATE}
fi

# output from the result(s) for check_mk
if ! [ -z "$warn" ]; then
    if ! [ -z "$ok" ]; then
        echo ${WARNING_STATE} certificate_keystore_validity - "these keystore(s) expire soon: $warn and these do not: $ok"
    else
        echo ${WARNING_STATE} certificate_keystore_validity - "these keystore(s) expire soon: $warn"
    fi
elif ! [ -z "$ok" ]; then
    echo ${OK_STATE} certificate_keystore_validity - "all keystore(s) are valid for more than 30 days: $ok"
else
    echo ${UNKNOWN_STATE} certificate_keystore_validity - "could not determine the status of $store, please check manually"
fi
