#!/bin/bash

set -e
set -u

case $# in
1 ) ;;
* ) echo "Usage: $0 <file>" >&2 ; exit 2 ;;
esac

file=$1
cat $file

trap 'rm -rf $tmp' EXIT
tmp=$(mktemp 2>/dev/null || mktemp -t ${0##*/})

sed "1s/.*/$MESSAGE/" $file >$tmp
mv $tmp $file
