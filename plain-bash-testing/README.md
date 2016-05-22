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
* The start function and continue functions should be in all-caps for
  readability.
* Framework functions called or implemented by you start with a single
  underscore.
* Internal functions and variables start with double underscore.  Do not call
  or use these.
* Support code goes in the `f/` directory.
* Tests go in the `t/` directory.

### Coding

* Do not call `exit`; instead use `return`.
* When possible use `local` variables in functions to avoid cross polution.
* Your functions follow particular rules:
  * Functions which can fail or error the test should use `_register`.
  * Other functions should finish with `"$@"`.
  * The start function is special.

## Implemented by you

Start by implementing:

### Start function

The name of the function is up to you.  Good choices include `SCENARIO` (BDD
style) and `CHECK` or `TEST` (unit test style).

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
It's only argument is the exit status of test functions:

* 0 - Passing test
* 1 - Failing test
* * - Errored test

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
    0 ) echo -e $pgreen$pcheckmark$preset $scenario_name ;;
    1 ) echo -e $pred$pballotx$preset $scenario_name ;;
    * ) echo -e $pboldred$pinterrobang$preset $scenario_name ;;
    esac
}
```
