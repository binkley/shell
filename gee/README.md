# gee - Git and Tee

This automates a common command-line pattern:

```
$ some command and args | tee some.out
```

Commits `some.out` to a hidden git repo so you can diff against previous
program runs, etc.

```
$ ./gee -h
Usage: gee [-h|-F FILE|-m MESSAGE|-o FILE] [PROGRAM ...]
Usage: gee [-h] -g PROGRAM [...]
Commit standard input or PROGRAM output, and also copy to standard output.

With no PROGRAM read standard input and name default out file '$1.out', 
otherwise name default out file 'gee.out'.

When '-g' run PROGRAM in the '.gee' repository and do not commit output.

  -h, --help              print help and exit normally
  -F, --file FILE         take the commit message from FILE
  -g, --in-repository     run PROGRAM in .gee
  -m, --message MESSAGE   commit using MESSAGE.  Multiple -m options are 
catenated as separate paragraphs
  -o, --out-file FILE     tee output to FILE relative to .gee

Examples:
  make test | gee -o test.out -m 'make test'
  gee make
  gee -g git log
```

## Tests

In progress.
