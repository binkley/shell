# binkley's Shell Scripts and Programs

## Contents

Helpful shell scripts and programs.

* [color](color/README.md) - Working with 8- and 24-bit color in the terminal
* [coverage](coverage) - Check JVM Maven project coverage with JaCoCo and
  Pitest
* [fibs](fibs) - Matrix math with Fibonacci Q-matrix
* [gee](gee/README.md) - Git and tee mashup
* [git](git/README.md) - Git help and extensions
* [jurlq](jurlq) - Mash-up of curl and jq ("xpath" for JSON) (Deprecated: use
HTTPie)
* [ksh](ksh) - KSH-specific scripting
* [maven-bash-testing](maven-bash-testing/README.md) - Maven driving Bash
* [maven-tools](maven-tools) - Helper scripts for maven repos
* [mdv](mdv) - Markdown viewer
* [open](open) - Launch UI programs from the command line
* [plain-bash-testing](plain-bash-testing/README.md) - Bash test framework
* [rls](rls) - Handle GPG from command line for other programs
* [run-jvm-main](run-jvm-main) - Run executable jar including auto-rebuild
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
* `mdv` - Markdown viewer

## TODO

* Top-level make does not know about working offline

## Resources

* [_Advanced Bash-Scripting Guild_](http://www.tldp.org/LDP/abs/html/)
