#!/bin/bash

set -e
set -u

case $# in
1 ) ;;
* ) echo "Usage: $0 <file>" >&2 ; exit 2 ;;
esac

file=$1
mv $file $BUFFER

sed "1s/.*/$MESSAGE/" <$BUFFER >$file
