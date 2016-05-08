#!/bin/bash

set -e

for d in *
do
    if [[ -f $d/Makefile ]]
    then
        (cd $d ; make)
    elif [[ -f $d/pom.xml ]]
    then
        (cd $d ; mvn clean verify)
    fi
done >/dev/null
