#!/bin/bash

function enable_debug()
{
    export debug=true
    export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '
    set -o functrace
    set -o pipefail
    set -o xtrace
}

if ${debug-false}
then
    enable_debug
fi

set -o errexit
set -o pipefail

job_file=META-INF/jobs

trap 'rm -f $all_jobs' EXIT
all_jobs=$(mktemp)

rootdir=$(dirname $0)
for jar in $rootdir/lib/*.jar
do
    if [[ $jar == "$rootdir/lib/*.jar" ]]
    then
        echo "$0: No jars to search for jobs" >&2
        exit 2
    fi

    unzip -qc $jar $job_file \
        | sed -e 's/#.*//' -e '/^$/d' -e "s;^;$jar ;"
done | sort -k1,2 >$all_jobs

function print_usage()
{
    cat <<EOU
Usage: $0 [-J-jvm_flag ...][-d|--debug][-h|--help][--health][-j|--jobs][-n|--dry-run][-v|--verbose] [--] [-job_flag ...] [job_arg ...]
EOU
}

function format_job()
{
    sed -e 's/-D\([^=]*\)=\$[1-9][0-9]*/<\1>/g'
}

function print_help()
{
    print_usage
    cat <<EOH

Flags:
  -J-*           JVM flags prefixed with J
  -d, --debug    Print debug output while running
  -h, --help     Print help and exit normally
  --health       Check job health and exit
  -j, --jobs     List jobs and exit normally
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output

Jobs:
EOH
    last_jar=''
    while read jar job_defn
    do
        if [[ $jar != $last_jar ]]
        then
            last_jar=$jar
            echo "  * ${jar##*/}:"
        fi
        echo -n "    - "
        echo "$job_defn" | format_job
    done <$all_jobs
}

function list_jobs()
{
    cut -d' ' -f2- <$all_jobs | sort
}

debug=false
health=false
java=java
java_flags=()
verbose=false
while getopts :J:dhnv-: opt
do
    [[ - == $opt ]] && opt=$OPTARG
    case $opt in
    J ) java_flags=("${java_flags[@]}" "$OPTARG") ;;
    d | debug ) enable_debug ;;
    h | help ) print_help ; exit 0 ;;
    health ) health=true ;;
    j | jobs ) list_jobs ; exit 0 ;;
    n | dry-run ) java='echo java' ;;
    v | verbose ) verbose=true ;;
    * ) print_usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
0 ) print_usage >&2 ; exit 2 ;;
esac

while read jar job_defn job_rest
do
    case $job_defn in
    $1 ) job=$1 ; break ;;
    esac
done <$all_jobs

if [[ -z "$job" ]]
then
    echo "$0: No definition for job: $1 (try -h)"
    echo "Definitions:"
    sed 's/^/  /' <$all_jobs
    exit 2
fi
shift

if $health
then
    exec $java "${java_flags[@]}" -jar $jar --health $job
fi

job_args=()
for arg in $(eval echo $job_rest)
do
    case $arg in
    -D* ) java_flags=("${java_flags[@]}" "$arg") ;;
    * ) job_args=("${job_args[@]}" "$arg") ;;
    esac
done

exec $java "${java_flags[@]}" -jar $jar $job "${job_args[@]}"
