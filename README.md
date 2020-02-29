# binkley's Shell Scripts and Programs

## Contents

Helpful shell scripts and programs.

* [color](color/README.md) - Working with 8- and 24-bit color in the terminal
* [fibs](fibs) - Matrix math with Fibonacci Q-matrix
* [gee](gee/README.md) - Git and tee mashup
* [git](git/README.md) - Git help and extensions
* [jurlq](jurlq) - Mash-up of curl and jq ("xpath" for JSON) (Obsolete: use
HTTPie)
* [ksh](ksh) - KSH-specific scripting
* [maven-bash-testing](maven-bash-testing/README.md) - Maven driving Bash
* [maven-tools](maven-tools) - Helper scripts for maven repos
* [mdv](mdv) - Markdown viewer
* [open](open) - Launch UI programs from the command line
* [plain-bash-testing](plain-bash-testing/README.md) - Bash test framework
* [md2man-pandoc](md2man-pandoc) - Convert markdown to man and view with pandoc
* [rls](rls) - Handle GPG from command line for other programs
* [svn-recommit](svn-recommit/README.md) - Reedit an SVN commit message
* [starter](starter/README.md) - Starter script for writing commands in BASH
* [unicode](unicode/README.md) - Work with UNICODE data
* [workaround-for-jenv-on-cygwin](workaround-for-jenv-on-cygwin) - Until jenv.be supports Cygwin

## Building

```
$ make
```

On success exits 0 and prints no output.  On failures, should be noisy and
in color (when run on a suitable terminal).  However, parse errors by BASH will not be in color: it is too early to have enabled color support.

## Tools in this directory

* `fibs` - Shows off the Fibonacci Q matrix with Bash integer math
* `md2man-pandoc` - Build man page from markdown

## TODO

* Top-level make does not know about working offline
