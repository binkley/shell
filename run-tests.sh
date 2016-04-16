#!/bin/bash

set -e

function run_tests {
    local d=$1
    shift

    trap popd RETURN
    pushd $d
    if [[ -f Makefile ]]
    then
        make
    elif [[ -f pom.xml ]]
    then
        mvn verify
    else
        echo "$d: No Makefile or pom.xml"
        exit 2
    fi
}

for d in *
do
    [[ -d $d ]] || continue
    run_tests $d
done
