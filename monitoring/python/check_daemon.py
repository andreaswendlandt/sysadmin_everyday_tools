#!/usr/bin/env python3
# author: andreas wendlandt
# desc: simple nagios/icinga plugin for checking if a daemon is running
# last modified: 13.09.2024

import os, sys

# exit codes
ok_state=0
critical_state=2
warning_state=1
unknown_state=3

# check that one argument was passed(the name of the daemon)
arg_number = len(sys.argv) -1
if arg_number != 1:
    print("wrong number of arguments")
    print("usage: " + sys.argv[0] + " <service>")
    exit(unknown_state)
else:
    service_name = sys.argv[1]

status = os.system('service ' + service_name + ' status >/dev/null 2>&1')

if status == 0:
    print('OK, service ' + service_name + ' is running')
    exit(ok_state)
else:
    print('CRITICAL, service ' + service_name + ' is not running')
    exit(critical_state)
