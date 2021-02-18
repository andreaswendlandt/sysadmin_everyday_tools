#!/bin/bash
# author: awendlandt
# desc: collecting version data for the compare_version check
# last modified: 26.02.2021
# note: on server1-4 must be a check_mk_agent that returns one or more versions in the way '1.2.3.4 version'

# fetching version data from servers with check_mk agent running on(port 6556)
exec 11<>/dev/tcp/ip_address/6556
cat <&11 | egrep '[0-9] version' | awk '{print $2 " " $4}' >/tmp/server1_result
exec 12<>/dev/tcp/ip_address/6556
cat <&12 | egrep '[0-9] version' | awk '{print $2 " " $4}' >/tmp/server2_result
exec 13<>/dev/tcp/ip_address/6556
cat <&13 | egrep '[0-9] version' | awk '{print $2 " " $4}' >/tmp/server3_result
exec 14<>/dev/tcp/ip_address/6556
cat <&14 | egrep '[0-9] version' | awk '{print $2 " " $4}' >/tmp/server4_result

# close file descriptors
exec 11>&-
exec 12>&-
exec 13>&-
exec 14>&-
