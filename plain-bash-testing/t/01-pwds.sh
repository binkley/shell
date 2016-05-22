# vi: ft=bash
# Source me

SCENARIO "Change directory" change_d /tmp
SCENARIO "Check directory cd" check_d $PWD
SCENARIO "Push directory" push_d /etc
SCENARIO "Check directory pushd" check_d $PWD
