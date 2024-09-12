#!/usr/bin/env python3
# author: andreas wendlandt
# desc: simple nagios/icinga plugin for checking if a reboot is required on a system
# note: this only works for debian/ubuntu systems
# last modified: 18.03.2021

import os
from pathlib import Path

# exit codes
ok_state=0
critical_state=2
warning_state=1
unknown_state=3

hostname = os.uname()[1]

reboot_required_file = Path("/var/run/reboot-required")

if reboot_required_file.exists():
    print('WARNING, a reboot is required on %s' % hostname)
    exit(warning_state)
else:
    print('OK, a reboot is not required on %s' % hostname)
    exit(ok_state)
