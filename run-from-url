#!/bin/bash

export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '

set -e

function print_usage {
    cat <<EOU
Usage: $0 [-hou] <url> <file> [...]
Usage: $0 -i [-hou] [--] [...]
EOU
}

function print_help {
    print_usage
    cat <<'EOH'

Runs a local copy of a script fetched from the Internet, caching based on
ETag.

Arguments:
  url             URL to update from
  file            Local copy to run

Options:
  -h,--help       Print help and exit normally
  -i,--inplace    Run inplace
  -o,--offline    Run local copy, do not update
  -u,--update     Update local copy, do not run

If <name> is the script name, caches the ETag for <url> in .<name>.etag.

If run inplace and <name> is the script name, the local copy is .<name> and
the URL is read from .<name>.url.  Use -- to distinguish flags for this script
from flags for the local copy.
EOH
}

inplace=false
offline=false
update=false
while getopts :hiou-: opt
do
    [[ - == $opt ]] && opt="${OPtARG%%=*}" OPTARG="${OPTARG#*=}"
    case $opt in
    h | help ) print_help ; exit 0 ;;
    i | inplace ) inplace=true ;;
    o | offline ) offline=true ;;
    u | update ) update=true ;;
    * ) print_usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

if $offline && $update
then
    echo "$0: Both -o and -u" >&2
    exit 2
fi

name=$(basename $0)
if $inplace
then
    pushd $(dirname $0)
    url_file=$PWD/.$name.url
    url=$(<$url_file)
    content_file=$PWD/.$name
    popd
    set -- $url $content_file "$@"
fi >/dev/null

case $# in
0 | 1 ) print_usage >&2 ; exit 2 ;;
* ) url=$1
    case $2 in
    /* ) content_file=$2 ;;
    * ) content_file=$PWD/$2 ;;
    esac
    readonly url content_file ;;
esac
shift 2

if $offline
then
    exec $content_file "$@"
fi

case $name in
    .* ) etag_file=$(dirname $content_file)/$name.etag ;;
    * ) etag_file=$(dirname $content_file)/.$name.etag ;;
esac
readonly etag_file
[[ -s $etag_file ]] || echo 0 >$etag_file
readonly old_etag=$(<$etag_file)

trap 'rm -rf $tmp_dir' EXIT
tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t ${0##*/})
tmp_headers_file=$tmp_dir/headers
tmp_content_file=$tmp_dir/content

read http_code < <(curl -s -D $tmp_headers_file -o $tmp_content_file \
    -w '%{http_code}\n' \
    -H "If-None-Match: \"$old_etag\"" \
    $url)
readonly http_code

case $http_code in
304 ) rm -rf $tmp_dir ; exec $content_file "$@" ;;
200 ) ;;
* ) echo "$0: Reponse $http_code for $url" >&2
    exit 3 ;;
esac

while read header value
do
    [[ ETag: == $header ]] || continue
    new_etag=${value%$'\r'}
    new_etag=${new_etag#\"}
    new_etag=${new_etag%\"}
    break
done <$tmp_headers_file
readonly new_etag

if [[ -z "$new_etag" ]]
then
    echo "$0: No ETag for $url" >&2
    exit 2
fi

mv $tmp_content_file $content_file
chmod +x $content_file
echo $new_etag >$etag_file

rm -rf $tmp_dir
exec $content_file "$@"
