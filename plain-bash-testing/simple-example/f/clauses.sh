function color_of {
    local -r fruit="$1"
    case $fruit in
    avacado ) echo greenish ;;
    orange ) echo orange ;;
    rambutan ) echo red ;;
    strawberry ) echo red ;;
    * ) echo "$0: Unknown fruit: $fruit" >&2
        return 2 ;;  # Not exit!
    esac
}

# For GIVEN - cannot fail or error, so do not `_register`
function a_rome_apple {
    local -r expected_color="red"
    "$@"
}

# For WHEN
function fruit_is {
    local -r fruit="$1"
    local actual_color
    case $fruit in
    avacado ) actual_color="greenish" ;;
    orange ) actual_color="orange" ;;
    rambutan ) actual_color="red" ;;
    strawberry ) actual_color="red" ;;
    * ) echo "$0: Unknown fruit: $fruit" >&2
        return 2 ;;  # Not exit!
    esac
}
_register fruit_is 1

# For THEN
function the_colors_agree {
    [[ "$actual_color" == "$expected_color" ]]
}
_register the_colors_agree
