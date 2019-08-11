# Starter

[bash-it-up.sh](bash-it-up.sh) is a starter script for writing commands in
BASH.

## Features

* Full help
* Long option arguments
* Debugging script itself
* Dry-run example
* Disable color if in a pipe
* Segregated tasks (sub-commands) into separate files
* Sample tasks (sub-commands) with individual help
* [Task dependency ordering](#task-dependency-ordering)

## Task dependency ordering

For a small project, using `make` to decide which tasks to run is overkill.
However, on larger project, those with multiple possibly programs to run, and
dependencies&mdash;shared or common&mdash;among them, it is simpler to
describe the dependencies, rather than write logic to do so.
