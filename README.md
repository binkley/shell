# binkley's Shell Scripts and Programs

## Contents

Helpful shell scripts and programs.

* [color](color/README.md) - Working with 8- and 24-bit color in the terminal
* [fibs](fibs) - Matrix math with Fibonacci Q-matrix
* [gee](gee/README.md) - Git and tee
* [git](git/README.md) - Git help and extensions
* [maven-bash-testing](maven-bash-testing/README.md) - Maven driving Bash
* [maven-tools](maven-tools) - Helper scripts for maven repos
* [plain-bash-testing](plain-bash-testing/README.md) - Bash test framework
* [md2man-pandoc](md2man-pandoc) - Convert markdown to man and view with pandoc
* [run-from-url](run-from-url) - Fetch and run script, keep up to date
* [svn-recommit](svn-recommit/README.md) - Reedit an SVN commit message
* [starter](starter/README.md) - Starter script for writing commands in BASH
* [unicode](unicode/README.md) - Work with UNICODE data

## Building

```
$ make
```

On success exits 0 and prints no output.  On failures, should be noisy and
in color (when run on a suitable terminal).  However, parse errors by BASH will not be in color: it is too early to have enabled color support.

## Tools in this directory

* `fibs` - Shows off the Fibonacci Q matrix with Bash integer math
* `md2man` - Build man page from markdown
* `run-from-url` - Keeps my local, running copy of a Github script up to date

## TODO

* Top-level make does not know about working offline
