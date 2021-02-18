#!/bin/bash
# author: awendlandt
# desc: check_mk plugin for comparing the installed docker versions(or any other versions) of several servers
# last modified: 27.02.2021

##########################################################################################
# debugging hint:                                                                        #
# this check depends on some running and successfully executed cronjobs:                 #
#33 * * * * /root/scripts/collect_versions.sh                                            #
# keep in mind that if you face some issues with this script, check that cronjob first!!!#
##########################################################################################

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# check file is older than 120 minutes function
check_file_too_old(){
    file_to_check="$1"
    cur_date=$(date +%s)
    file_too_old=$(stat -L --format %Y $file_to_check)
    if [ $(($cur_date-$file_too_old)) -ge 7200 ]; then
        return 0
    else
        return 1
    fi
}

if check_file_too_old /tmp/server1_result || check_file_too_old /tmp/server2_result || check_file_too_old /tmp/server3_result || check_file_too_old /tmp/server4_result; then
    echo ${UNKNOWN_STATE} version_docker - "one or more result files under /tmp are too old, please check manually" 
    exit 1
fi

# check file exists and is not empty function
check_file_exists_and_is_not_empty(){
    file_to_check="$1"
    for (( i=1; i<20; i++ )); do
        if [ -s "$file_to_check" ]; then
            return 0
        else
            sleep 2
        fi
     done
     return 1
}

# servers to check docker versions from (server[1-4])
# (collect data via the collector script)
if check_file_exists_and_is_not_empty /tmp/server1_result; then
    server1=$(</tmp/server1_result)
fi
if check_file_exists_and_is_not_empty /tmp/server2_result; then
    server2=$(</tmp/server2_result)
fi
if check_file_exists_and_is_not_empty /tmp/server3_result; then
    server3=$(</tmp/server3_result)
fi
if check_file_exists_and_is_not_empty /tmp/server4_result; then
    server4=$(</tmp/server4_result)
fi

if [ -z "$server1" -o -z "$server2" -o -z "$server3" -o -z "$server4" ]; then
    echo ${UNKNOWN_STATE} version_docker - "one or more result files under /tmp are empty, please check manually" 
    exit 1
fi

# compare version function
compare_version(){
    i=0
    equal=0
    is_equal=0
    is_not_equal=0
    result_is_equal=
    result_is_not_equal=
    empty_result=0
    for server in $2; do
        version_to_check=$1
        version=$(echo "${!server}" | grep $version_to_check | awk '{print $2}')
        version="${version%%[[:cntrl:]]}"
        if [ -z "$version" ]; then
            empty_result=1
        else
            eval ${server}_version="$version"
            if [ $i -eq 0 ]; then
                ref_version="$version"
                ref_server="$server - $ref_version"
            else
                if [ "$ref_version" == "$server_$version" ]; then
                    is_equal=1
                    result_is_equal="$result_is_equal $server - $server_$version"
                else
                    is_not_equal=1
                    result_is_not_equal="$result_is_not_equal $server - $server_$version"
                fi
            fi
        fi
        i=$((i+1))
    done
    if [ $empty_result -eq 1 ]; then
        echo ${UNKNOWN_STATE} ${version_to_check} - "could not determine the versions for servers($2)"
    elif ! [ -z $is_not_equal ] && [ $is_not_equal -eq 1 ]; then
        echo ${WARNING_STATE} ${version_to_check} - "$version_to_check is not equal on all servers ($ref_server $result_is_equal $result_is_not_equal)"
    elif [ $is_equal -eq 1 ]; then
        echo ${OK_STATE} ${version_to_check} - "$version_to_check($ref_version) is equal on all servers($2)"
    else
        echo ${UNKNOWN_STATE} ${version_to_check} - "could not determine the version of $version_to_check on $2, please check manually"
    fi
}

compare_version version_docker "server1 server2 server3 server4"
