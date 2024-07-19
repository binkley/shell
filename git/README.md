# Git

Git help and extensions

* [cygwin-pre-commit](cygwin-pre-commit) - Pre-commit hook for Cygwin line
  endings and execute bits
* [git-hooks](git-hooks) - TDD extension for hook management
* [git-tdd](git-tdd) - TDD extension for git focused on frequent commits

## `cygwin-pre-commit`

Working on Cygwin presents some challenges when sharing code, e.g., GitHub and
competitors.  This _pre-commit_ hook handles most issues most times:

* De-dosify non-DOS text files
* De-unixfy DOS text files
* Fix the execute bit on scripts
* Leave binaries and symlinks alone

## `git hooks`

## `git tdd`

### Rationale

* Always test code!  Do not commit unless tests pass.
* Test frequently, so commit _locally_ frequently.
* Share code (push) when something is ready to share, not partway done.
* Avoid _partial commits_: they are a common cause of "works for me".
* Get in a good command line cycle: edit, tests pass, commit, repeat.

### Concepts

_WIP_ - The "work in progress" is a local commit holding all files when tests
have passed.  Each passing test cycle amends the WIP commit.

_Accepting_ - When work is ready to share, "accepting" runs tests one last
time (possibly more complete or expensive tests) before pushing, and starting
a new, empty WIP commit.

### Subcommands

* `tdd init` - First time setup, needed for other subcommands.  Repo should
  have at least one commit prior (even if an empty commit).
* `tdd status` - Shows which files are committed to WIP, which are untested.
* `tdd test` - Runs tests and commits locally to WIP if passing.
* `tdd accept` - Runs tests and pushes if passing.  Starts a new WIP.

## TODO

* Fix broken tests in `git` because of colorized output
* Investigate `git tdd init` when there is something already stashed
* Add manpages
