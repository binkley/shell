#!/bin/bash

set -e
set -u

function print_usage {
    cat <<EOU
Usage: $0 [-h|--help] <svn-revision>
EOU
}

function print_help {
    print_usage
    cat <<'EOH'

Edits a single SVN commit message in the current working directory.

Arguments:
  svn-revision    SVN revision number

Options:
  -h, --help    Print help and exit normally
EOH
}

function make_tmp {
    local tmp=svn-commit.tmp
    let n=1
    while [[ -e $tmp ]]
    do
        let ++n
        tmp=svn-commit.$n.tmp
    done
    echo $tmp
}

while getopts :h-: opt
do
    [[ - == $opt ]] && opt=${OPTIND%%=*} OPTARG=${OPTARG%*=}
    case $opt in
    h | help ) print_help ; exit 0 ;;
    * ) print_usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
1 ) revision=$1 ; shift ;;
* ) print_usage >&2 ; exit 2 ;;
esac

if ! svn info >/dev/null 2>&1
then
    echo "$0: Not an SVN working directory: $PWD" >&2
    exit 2
fi

trap 'rm -f $tmp' EXIT
tmp=$(make_tmp)

original="$(svn propget --revprop -r $revision svn:log)"
flavor_text='--This line, and those below, will be ignored--'

echo "$original" >$tmp
echo "$flavor_text" >>$tmp
echo >>$tmp
svn log -r $revision -v \
    | grep '^   ' \
    | while read action path
do
    echo "$action    $path"
done >>$tmp

${VISUAL=${EDITOR-vi}} $tmp
read -r -d '' replacement < <(sed "/^$flavor_text\$/,\$d" $tmp) && true

[[ -n "$replacement" && "$original" != "$replacement" ]] \
    && exec svn propset --revprop -r $revision svn:log \
    "$replacement" >/dev/null
