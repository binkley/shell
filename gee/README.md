# gee - Git and Tee mashup, or committing `<STDOUT>`

This automates a common command-line pattern:

```
$ some command and args | tee some.out
```

Commits `some.out` to a hidden git repo so you can diff against previous
program runs, etc.  For example:

```
$ gee -o verify.out mvn clean verify
# Edit, edit, edit
$ gee -o verify.out mvn clean verify
# See how the build changed
$ gee -g git diff HEAD^ verify.out
```

Note that in a case like maven, I need to do some additional filtering or
[change the output format](https://maven.apache.org/maven-logging.html) to
remove timestamps from the output and avoid spurious differences.

```
Usage: gee [-F FILE|-hl|-m MESSAGE|-o FILE][-u] [PROGRAM ...]
Usage: gee [-h] -g PROGRAM [...]
Commit standard input or PROGRAM output, and also copy to standard output.

With no PROGRAM, read standard input and name default out file 'gee.out', 
otherwise name default out file 'PROGRAM.out'.

With '-l', commit output to local git, not '.gee' directory.

With '-g', run PROGRAM in the '.gee' repository and do not commit output.

  -h, --help              print help and exit normally
  -l, --local             use local .git, not .gee
  -F, --file FILE         take the commit message from FILE
  -g, --in-repository     run PROGRAM in .gee
  -m, --message MESSAGE   commit using MESSAGE.  Multiple -m options are 
catenated as separate paragraphs
  -o, --out-file FILE     tee output to FILE relative to .gee
  -u, --log-unchanged     update commit even when there are no changes

Examples:
  make test | gee -o test.out -m 'make test'
  gee make test
  gee -g git diff HEAD^
```

## Tests

Run `make`.

This runs `test-gee -i -- -c t`  Interestingly, this is not a
test script!  It's a copy of
[run-from-url](https://github.com/binkley/shell/blob/master/run-from-url)
which runs a cached copy of
[run-tests](https://github.com/binkley/shell/blob/master/plain-bash-testing/run-tests).
This keeps the test script always up to date.
