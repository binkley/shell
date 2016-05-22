# vi: ft=bash
# Source me

SCENARIO "Normal return pass direct" normal_return 0
SCENARIO "Normal return fail direct" normal_return 1
SCENARIO "Normal return error direct" normal_return 2
SCENARIO "Normal return pass indirect" f AND normal_return 0
SCENARIO "Normal return fail indirect" f AND normal_return 1
SCENARIO "Normal return error indirect" f AND normal_return 2
SCENARIO "Early return pass indirect" f AND early_return 0
SCENARIO "Early return fail indirect" f AND early_return 1
SCENARIO "Early return error indirect" f AND early_return 2
SCENARIO "Early return pass direct" early_return 0
SCENARIO "Early return fail direct" early_return 1
SCENARIO "Early return error direct" early_return 2
