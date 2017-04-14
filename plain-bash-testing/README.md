# Plain testing with Bash

## What is this?

This is a simple, general test framework for Bash.  It relies on a few
conventions, otherwise is self-bootstrapping.

## Which tests to run?

Run all tests in a directory tree:
```bash
$ ./run-tests t
```
Run all test in a file(s):
```bash
$ ./run-tests t/happy-path.sh
```
Run tests matching a pattern:
```bash
$ ./run-tests --pattern='needs work' t
```

## What happened?

You can use a single `-d` (`--debug`) switch to enable bash debug printing of
the tests.  Use two of them to debug `run-tests` itself.

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
  * Use the global `exit_code` variable to signal failure (the default
    `_print_result` will show this).
* When possible use `local` variables in functions to avoid escaping scope.
* Your functions follow particular rules:
   * Functions which can fail or error the test should use `_register`.
   * Other functions should finish with `"$@"`.
   * The start function is special.
* If you need a temporary directory (a common need), use `_new-tempdir-into`
  with a variable name to store the tmpdir into, and it will be cleaned up
  when tests conclude.

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

This is _OPTIONAL_.  The default `_print_function` is informative and colorful.

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

More interesting (but less interesting than the default `_print_result`):

```bash
function _print_result {
    local -r _e=$1
    local -r _function_name=$2
    $_quiet && return $_e
    case $_e in
    0 ) echo -e $ppass $scenario_name ;;
    1 ) echo -e $pfail $scenario_name ($_function_name) ;;
    * ) echo -e $perror $scenario_name ($_function_name) ;;
    esac
}
```

The default definitions of test status markers are (relying on a console which
supports UNICODE; most do):

* pass - a green check mark
* fail - a red X
* error - a bold red interrobang

## Writing tests

Keep each test on _one line_, using backslash line continuation for
readability.  This supports both `run-tests` executing your entire test as a
single statement, and using patterns to filter which tests to run.

## A simple example

An example mini BDD language in [`simple-example`](simple-example/):

### `f/framework.sh`

```bash
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
