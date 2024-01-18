#!/bin/bash
# author: andreaswendlandt
# desc: simple check_mk plugin for checking that a git repo is available and usable
# last modified: 22.05.2020
# prerequisites: a valid user to authenticate agains the remote git/bitbucket server
# hint: create a .netrc file in the home folder of whoever executes this, some examples can be found here:
# https://www.labkey.org/Documentation/wiki-page.view?name=netrc

# exit codes
OK_STATE=0
CRITICAL_STATE=2
WARNING_STATE=1
UNKNOWN_STATE=3

# the repo path, the content of the testfile(always the current unix time string) and the commit message
repo_path="path_to_your_repo"
file_content=$(date +%s)
commit_message="$(date): update testfile"

cd $repo_path 2>/dev/null

if git pull >/dev/null 2>&1; then
    echo "$file_content" >testfile
    git add testfile >/dev/null 2>&1
    git commit -m "$commit_message" >/dev/null 2>&1
    if git push -u origin master >/dev/null 2>&1; then
        echo ${OK_STATE} Bitbucket - "changed, added, committed and pushed successfully a testfile"
    else
        echo ${WARNING_STATE} Bitbucket - "could not push to repo, please check manually"
    fi
else
    echo ${WARNING_STATE} Bitbucket - "repo seems not available(could not pull), please check manually"
fi
