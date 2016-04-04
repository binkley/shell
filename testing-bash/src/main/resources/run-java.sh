#!/bin/bash

set -o errexit
set -o pipefail

task_file=META-INF/tasks

trap 'rm -f $all_tasks' EXIT
all_tasks=$(mktemp)

rootdir=$(dirname $0)
for jar in $rootdir/lib/*.jar
do
    if [[ $jar == "$rootdir/lib/*.jar" ]]
    then
        echo "$0: No jars to search for tasks" >&2
        exit 2
    fi

    unzip -qc $jar $task_file \
        | sed -e 's/#.*//' -e '/^$/d' -e "s;^;$jar ;"
done | sort -k1,2 >$all_tasks

function print_usage()
{
    cat <<EOU
Usage: $0 [-J-jvm_flag ...][-h|--help][--health][-n|--dry-run][-v|--verbose] [--] [-task_flag ...] [task_arg ...]
EOU
}

function format_task()
{
    sed -e 's/-D\([^=]*\)=\$[1-9][0-9]*/<\1>/g'
}

function print_help()
{
    print_usage
    cat <<EOH

Flags:
  -J-*           JVM flags prefixed with J
  -h, --help     Print help and exit
  --health       Check task health and exit
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output

Tasks:
EOH
    last_jar=''
    while read jar task_defn
    do
        if [[ $jar != $last_jar ]]
        then
            last_jar=$jar
            echo "  * ${jar##*/}:"
        fi
        echo -n "    - "
        echo "$task_defn" | format_task
    done <$all_tasks
}

health=false
java=java
java_flags=()
verbose=false
while getopts :J:hnv-: opt
do
    [[ - == $opt ]] && opt=$OPTARG
    case $opt in
    J ) java_flags=("${java_flags[@]}" "$OPTARG") ;;
    h | help ) print_help ; exit 0 ;;
    health ) health=true ;;
    n | dry-run ) java='echo java' ;;
    v | verbose ) verbose=true ;;
    * ) print_usage >&2 ; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

case $# in
0 ) print_usage >&2 ; exit 2 ;;
esac

while read jar task_defn task_rest
do
    case $task_defn in
    $1 ) task=$1 ; break ;;
    esac
done <$all_tasks

if [[ -z "$task" ]]
then
    echo "$0: No definition for task: $1 (try -h)"
    echo "Definitions:"
    sed 's/^/  /' <$all_tasks
    exit 2
fi
shift

if $health
then
    exec $java "${java_flags[@]}" -jar $jar --health $task
fi

task_args=()
for arg in $(eval echo $task_rest)
do
    case $arg in
    -D* ) java_flags=("${java_flags[@]}" "$arg") ;;
    * ) task_args=("${task_args[@]}" "$arg") ;;
    esac
done

exec $java "${java_flags[@]}" -jar $jar $task "${task_args[@]}"
