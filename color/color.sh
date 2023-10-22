# Source me
# See https://en.wikipedia.org/wiki/ANSI_escape_code

printf -v preset "\e[0m"

printf -v pbold "\e[1m"
printf -v plight "\e[2m"
printf -v pitalic "\e[3m"
printf -v punderline "\e[4m"
printf -v pblink "\e[5m"
printf -v prapidblink "\e[6m" # Poorly supported
printf -v preverse "\e[7m" # Poorly supported
printf -v pinvisible "\e[8m" # Poorly supported
printf -v pstrikethrough "\e[9m"

# Codes 10-21 are about font shifting -- poorly supported
printf -v pprimaryfont "\e[10m"
printf -v palternativefont11 "\e[11m"
printf -v palternativefont12 "\e[12m"
printf -v palternativefont13 "\e[13m"
printf -v palternativefont14 "\e[14m"
printf -v palternativefont15 "\e[15m"
printf -v palternativefont16 "\e[16m"
printf -v palternativefont17 "\e[17m"
printf -v palternativefont18 "\e[18m"
printf -v palternativefont19 "\e[19m"
printf -v pfrakturfont "\e[20m"

printf -v pdoubleunderline "\e[21m"
printf -v pnormal "\e[22m" # Undo formatting, but preserve color
printf -v pnoitalicblackletter "\e[23m"
printf -v pnounderline "\e[24m" # Undo underline, but preserve other formatting
printf -v pnoblink "\e[25m" # Undo blink, but preserve other formatting
printf -v pproportionalspacing "\e[26m" # Irrelevant with fixed font terminals
printf -v pnoreverse "\e[27m" # Undo reversing, but preserve other formatting
printf -v pnoinvisible "\e[28m" # Undo hidden text, but preserve other formatting
printf -v pnostrikethrough "\e[29m" # Undo strikethrough, but preserve other formatting

# Easy colors
printf -v pblack "\e[30m"
printf -v pred "\e[31m"
printf -v pgreen "\e[32m"
printf -v pyellow "\e[33m"
printf -v pblue "\e[34m"
printf -v pmagenta "\e[35m"
printf -v pcyan "\e[36m"
printf -v pwhite "\e[37m"

printf $preset  # Clear changes to help debugging

if [[ -r "$X11_RGB_TXT" ]]
then
    readonly __8_color=false
else
    readonly __8_color=true
    echo "$0: Cannot read rgb.txt, limited to 8 colors: $X11_RGB_TXT" >&2
    # TODO: 'c' function for 8 colors
    return 2
fi

if declare -A __fg_colors 2>/dev/null
then
    hash_cache=true
    declare -A __bg_colors
else
    hash_cache=false
    declare -a __fg_colors __fg_values __bg_colors __bg_values
fi

: ${c_truecolor:=true}

if $c_truecolor
then
    function _fg {
        local -r r=$1
        local -r g=$2
        local -r b=$3
        printf '\e[38;2;%d;%d;%dm' $r $g $b
    }

    function _bg {
        local -r r=$1
        local -r g=$2
        local -r b=$3
        printf '\e[48;2;%d;%d;%dm' $r $g $b
    }
else
    function _fg {
        local -r r=$(( 5 * $1 / 255 ))
        local -r g=$(( 5 * $2 / 255 ))
        local -r b=$(( 5 * $3 / 255 )) 
        local -r rgb=$(( (36 * r) + (6 * g) + b + 16 ))
        printf '\e[38;5;%dm' $rgb
    }

    function _bg {
        local -r r=$(( 5 * $1 / 255 ))
        local -r g=$(( 5 * $2 / 255 ))
        local -r b=$(( 5 * $3 / 255 )) 
        local -r rgb=$(( (36 * r) + (6 * g) + b + 16 ))
        printf '\e[48;5;%dm' $rgb
    }
fi

if $hash_cache
then
    function _fg_cache {
        local -r name="$1"
        local -r value="$2"
        __fg_colors[$name]="$value"
    }

    function _bg_cache {
        local -r name="$1"
        local -r value="$2"
        __bg_colors[$name]="$value"
    }

    function _fg_printf {
        local -r name="$1"
        local -r value="${__fg_colors[$name]}"
        if [[ -n "$value" ]]
        then
            printf "$value"
            return
        fi
        echo "$0: $FUNCNAME: Unknown color: $name" >&2
        return 2
    }

    function _bg_printf {
        local -r name="$1"
        local -r value="${__bg_colors[$name]}"
        if [[ -n "$value" ]]
        then
            printf "$value"
            return
        fi
        echo "$0: $FUNCNAME: Unknown color: $name" >&2
        return 2
    }
else
    function _fg_cache {
        local -r name="$1"
        local -r value="$2"
        __fg_colors+=("$name")
        __fg_values+=("$value")
    }

    function _bg_cache {
        local -r name="$1"
        local -r value="$2"
        __bg_colors+=("$name")
        __bg_values+=("$value")
    }

    function _fg_printf {
        local -r name="$1"
        for i in ${!__fg_colors[@]}
        do
            if [[ "${__fg_colors[i]}" == "$name" ]]
            then
                printf ${__fg_values[i]}
                return
            fi
        done
        echo "$0: $FUNCNAME: Unknown color: $name" >&2
        return 2
    }

    function _bg_printf {
        local -r name="$1"
        for i in ${!__bg_colors[@]}
        do
            if [[ "${__bg_colors[i]}" == "$name" ]]
            then
                printf ${__bg_values[i]}
                return
            fi
        done
        echo "$0: $FUNCNAME: Unknown color: $name" >&2
        return 2
    }
fi

while read __r __g __b __name
do
    [[ -z "$__name" ]] && __name="$b" b=0
    # Inline _fg and _bg for performance
    if $c_truecolor
    then
        _fg_cache "$__name" "\e[38;2;$__r;$__g;${__b}m"
        _bg_cache "$__name" "\e[48;2;$__r;$__g;${__b}m"
    else
        __r=$(( 5 * __r / 255 ))
        __g=$(( 5 * __g / 255 ))
        __b=$(( 5 * __b / 255 )) 
        __rgb=$(( (36 * __r) + (6 * __g) + __b + 16 ))
        _fg_cache "$__name" "\e[38;5;${__rgb}m"
        _bg_cache "$__name" "\e[48;5;${__rgb}m"
    fi
done <$X11_RGB_TXT
unset __r __g __b __name __rgb

function c {
    case $# in
    1 | 3 ) set -- fg "$@" ;;
    2 | 4 ) case $1 in
        fg | bg ) ;;
        * ) echo "Usage: $0: $FUNCNAME [fg|bg] <named-color|red8 green8 blue8>" >&2
            exit 2 ;;
        esac ;;
    * ) echo "Usage: $0: $FUNCNAME [fg|bg] <named-color|red8 green8 blue8>" >&2
        exit 2 ;;
    esac

    local r g b
    case $2 in
    [0-9]* ) r=$2 g=$3 b=$3 ;;
    * ) case $1 in
        fg ) _fg_printf "$2" ;;
        bg ) _bg_printf "$2" ;;
        esac
        return ;;
    esac
    case $1 in
    fg ) _fg $r $g $b ;;
    bg ) _bg $r $g $b ;;
    esac
}

printf $preset  # Clear changes to help debugging
