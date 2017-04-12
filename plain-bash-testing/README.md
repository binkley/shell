# Plain testing with Bash

## What is this?

This is a simple, general test framework for Bash.  It relies on a few
conventions, otherwise is self-bootstrapping.

## Conventions

* Hook functions implement and extend the framework: do not edit framework
  functions.
* Tracking test status is a responsibility of the framework, not your test
  functions.
* Failing or erroring a test short circuit execution: invoke no further
  functions for that test.

### Naming

Picking out your code from framework code is simple:

* Test functions written by you all start with an alphabetic.
* The start function (e.g., `SCENARIO`) and continue functions (e.g., `AND`)
  should be in all-caps for readability.
* Framework functions called or implemented by you start with a single
  underscore.
* Internal functions and variables start with double underscore.  Do not call
  or use these.
* Framework code goes in the `f/` directory.
* Tests go in the `t/` directory.

### Coding

* Do not call `exit`; instead use `return`.
* When possible use `local` variables in functions to avoid escaping scope.
* Your functions follow particular rules:
   * Functions which can fail or error the test should use `_register`.
   * Other functions should finish with `"$@"`.
   * The start function is special.

## Implemented by you

Start by implementing:

### Start function

The name of the function is up to you.  Good choices include `SCENARIO` (BDD
style), and `CHECK` or `TEST` (unit test style).

Process any arguments, shift them off the stack, and finish the function with
`_start "$@"`.

Example:

```bash
function SCENARIO {
    local -r scenario_name="$1"
    shift
    _start "$@"
}
```

# Continue functions

Continue functions are "glue" between test functions for readability.
Generally they contain only `"$@"`.

Example:

```bash
function AND {
    "$@"
}
```

### `_print_result`

Individual test results may be shown by declaring a `_print_result` function.
It's only argument is the return code of test functions:

* 0 - Passing test
* 1 - Failing test
* `*` - Errored test (any return other than 0 or 1)

A "do nothing" function is:

```bash
function _print_result {
    :
}
```

More interesting might be:

```bash
function _print_result {
    local -r exit_code=$1
    $_quiet && return $exit_code
    case $exit_code in
    0 ) echo -e $ppass $scenario_name ;;
    1 ) echo -e $pfail $scenario_name ;;
    * ) echo -e $perror $scenario_name ;;
    esac
}
```

The default definitions of test status markers are (relying on a console which
supports UNICODE; most do):

* pass - a green check mark
* fail - a red X
* error - a bold red interrobang

## A simple example

An example mini BDD language in [`simple-example`](simple-example/):

### `f/framework.sh`

```bash
readonly pcheckmark=$(printf "\xE2\x9C\x93")
readonly ppass="$pgreen$pcheckmark$preset"
readonly pballotx=$(printf "\xE2\x9C\x97")
readonly pfail="$pred$pballotx$preset"
readonly pinterrobang=$(printf "\xE2\x80\xBD")
readonly perror="$pboldred$pinterrobang$preset"

function _print_result {
    local -r exit_code=$1
    $_quiet && return $exit_code
    case $exit_code in
    0 ) echo -e "$ppass $scenario_name" ;;
    1 ) echo -e "$pfail $scenario_name - wanted: $expected_color, got $actual_color" ;;
    * ) echo -e "$perror $scenario_name - exit: $exit_code" ;;
    esac
}

function THEN {
    "$@"
}

function WHEN {
    "$@"
}

function GIVEN {
    "$@"
}

function SCENARIO {
    local -r scenario_name="$1"
    shift
    _start "$@"
}

```

### `f/clauses.sh`

```bash
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
```

### `t/good-fruit.sh`

```bash
# These tests PASS

SCENARIO "Rambutans are red" \
    GIVEN a_rome_apple  \
    WHEN fruit_is rambutan \
    THEN the_colors_agree

SCENARIO "Strawberries are red" \
    GIVEN a_rome_apple \
    WHEN fruit_is strawberry \
    THEN the_colors_agree
```

### `t/bad-fruit.sh`

```bash
# These tests FAIL

SCENARIO "Avacados are greenish" \
    GIVEN a_rome_apple \
    WHEN fruit_is avacado \
    THEN the_colors_agree

SCENARIO "Oranges are orange" \
    GIVEN a_rome_apple \
    WHEN fruit_is orange \
    THEN the_colors_agree
```

### `t/ugly-fruit.sh`

```bash
# This test errors

SCENARIO "Ugli are yellow" \
    GIVEN a_rome_apple \
    WHEN fruit_is ugli \
    THEN the_colors_agree
```

## TODO

* Capture STDERR for simple commands so `_print_result` can update line, then show errors
