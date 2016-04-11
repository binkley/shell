# Testing BASH

This demonstrates [fluent](https://en.wikipedia.org/wiki/Fluent_interface)
[BDD-style unit testing](http://martinfowler.com/bliki/GivenWhenThen.html)
(given/when/then) in BASH.

## Techniques

Fluent coding relies on several BASH features:

* Variable expansion happens before executing commands
* A shell function is indistinguishable from a program: they are called the
  same way
* Local function variables are dynamically scoped but only within a function,
  so are visible to other functions called within that scope, directly or
  indirectly through further function calls

Together with
[Builder pattern](https://en.wikipedia.org/wiki/Builder_pattern), it's easy
to write given/when/then tests.  (Builder pattern here solves the problem
not of telescoping constructors, but long, arbitrary argument lists.)

So when you run:

```bash
function c {
    echo "$message"
}

function b {
    "$@"
}

function a {
    local message="$1"
    shift
    "$@"
}

a "Bob's your uncle" b c
```

You see the output:

```
Bob's your uncle
```

### How does this work?

First BASH expands variables.  In function `a` this means that after the first
argument is remembered and removed from the argument list, `"$@"` expands
to `b c`.  Then `b c ` is executed.

Then BASH calls the function `b` with the argument "c".  Similarly `b`
expands `"$@"` to `c` and calls it.

Finally as `$message` is visible in functions called by `a`, `c` prints the
first argument passed to `a` (as it was remebered in the variable
`$message`), or "Bob's your uncle" in this example.

Running the snippet with xtrace makes this clear (assuming the snippet is
saved in a file named `example`):

```
bash -x example
+ a 'Bob'\''s your uncle' b c
+ local 'message=Bob'\''s your uncle'
+ shift
+ b c
+ c
+ echo 'Bob'\''s your uncle'
Bob's your uncle
```

So the test functions for `given_jar`, `when_run` and `then_expect` (along
with other, similar functions) work the same way.  Keep this in mind.

## Key files

* [run-java.sh](src/main/resources/run-java.sh) - The script to test.  It is
  a medium-complexity BASH script integrating command line jobs into Java
  projects
* [test-run-java.sh](src/test/resources/test-run-java.sh) - Driver for
  running tests
* [test-functions.sh](src/test/resources/test-functions.sh) - BDD testing
  functions
* [t/*](src/test/resources/t/) - BDD-style tests
* [pom.xml](pom.xml) - Maven glue to run shell unit tests during `test` phase.
  Note respect given to `skipTests`
