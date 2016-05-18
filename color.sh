#/bin/bash

export PS4='+${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): } '

pbold=$(printf '\e[1m')
plight=$(printf '\e[2m')
pitalic=$(printf '\e[3m')
punderscore=$(printf '\e[4m')
pblink=$(printf '\e[5m')
preverse=$(printf '\e[7m')
pinvisible=$(printf '\e[8m')
pstrikethrough=$(printf '\e[9m')

declare -a effects
for v in ${!p*}
do
    effects+=(${v#p})
done

preset=$(printf '\e[0m')

pblack=$(printf '\e[30m')
pred=$(printf '\e[31m')
pgreen=$(printf '\e[32m')
pyellow=$(printf '\e[33m')
pblue=$(printf '\e[34m')
pmagenta=$(printf '\e[35m')
pcyan=$(printf '\e[36m')
pwhite=$(printf '\e[37m')
printf $preset

for e in ${effects[*]}
do
    echo This is $e
    for c in black red green yellow blue magenta cyan white
    do
        eval "printf \" \${p$e}\${p$c}$c\$preset\""
    done
    echo
done
echo Done

{
    pushd $(dirname $0)
    root_dir=$(pwd -P)
    popd
} >/dev/null

: ${X11_RGB_TXT:=/usr/share/X11/rgb.txt}
[[ -r $X11_RGB_TXT ]] || X11_RGB_TXT=$root_dir/rgb.txt

truecolor=false
declare -A fg_colors 2>/dev/null && cached_colors=true || cached_colors=false

function _truecolor_fg {
    printf '\e[38;2;%d;%d;%dm' $1 $2 $3
}

function _truecolor_bg {
    printf '\e[48;2;%d;%d;%dm' $1 $2 $3
}

function _256color_fg {
    local -r r=$(( 5 * $1 / 255 ))
    local -r g=$(( 5 * $2 / 255 ))
    local -r b=$(( 5 * $3 / 255 )) 
    local -r rgb=$(( (36 * r) + (6 * g) + b + 16 ))
    printf '\e[38;5;%dm' $rgb
}

function _256color_bg {
    local -r r=$(( 5 * $1 / 255 ))
    local -r g=$(( 5 * $2 / 255 ))
    local -r b=$(( 5 * $3 / 255 )) 
    local -r rgb=$(( (36 * r) + (6 * g) + b + 16 ))
    printf '\e[48;5;%dm' $rgb
}

if $cached_colors
then
    declare -A bg_colors 2>/dev/null
    declare -A colors 2>/dev/null
    while read r g b name
    do
        [[ -z "$name" ]] && name="$b" b=0
        colors[$name]="$r $g $b"
        if $truecolor
        then
            fg_colors[$name]=$(_truecolor_fg $r $g $b)
            bg_colors[$name]=$(_truecolor_bg $r $g $b)
        else
            fg_colors[$name]=$(_256color_fg $r $g $b)
            bg_colors[$name]=$(_256color_bg $r $g $b)
        fi
    done <$X11_RGB_TXT
    function _to_rgb {
        local -r p="${colors[$1]}"
        if [[ -n "$p" ]]
        then
            echo $p
            return
        fi
        echo "$0: $FUNCNAME: Unknown color: $1" >&2
        return 2
    }
else
    function _to_rgb {
        while read r g b name
        do
            [[ -z "$name" ]] && name="$b" b=0
            if [[ "$name" == "$1" ]]
            then
                echo $r $g $b
                return
            fi
        done <$X11_RGB_TXT
        echo "$0: $FUNCNAME: Unknown color: $1" >&2
        return 2
    }
fi

function c {
    case $# in
    2 | 4 ) ;;
    * ) echo "Usage: $0: $FUNCNAME <fg|bg> <named-color|red8 green8 blue8>" >&2
        exit 2 ;;
    esac
    case $1 in
    fg | bg ) ;;
    * ) echo "Usage: $0: $FUNCNAME <fg|bg> <named-color|red8 green8 blue8>" >&2
        exit 2 ;;
    esac
    local r g b
    case $2 in
    [0-9]* ) r=$2 g=$3 b=$3 ;;
    * ) if $cached_colors
        then
            case $1 in
            fg ) printf ${fg_colors[$2]} ;;
            bg ) printf ${bg_colors[$2]} ;;
            esac
            return
        else
            read r g b < <(_to_rgb $2)
        fi ;;
    esac
    case $1 in
    fg ) $truecolor && _truecolor_fg $r $g $b || _256color_fg $r $g $b ;;
    bg ) $truecolor && _truecolor_bg $r $g $b || _256color_bg $r $g $b ;;
    esac
}

if true
then
    for r in $(seq 5 10 255)
    do
        c bg $r 0 0
        printf '  '
    done
    printf '\e[0m\n'
fi

for color
do
    printf "$(c fg $color)$color$preset\n"
done
