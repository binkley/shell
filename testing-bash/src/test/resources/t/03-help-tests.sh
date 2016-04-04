# Source me - do not execute

scenario "Short option help" \
    given_jar a.jar with_tasks 'simple-task' \
        also_jar b.jar with_tasks 'trivial-task' \
    when_run '-h' \
    then_expect <<'EOE'
Usage: ./run-java.sh [-J-jvm_flag ...][-h|--help][--health][-n|--dry-run][-v|--verbose] [--] [-task_flag ...] [task_arg ...]

Flags:
  -J-*           JVM flags prefixed with J
  -h, --help     Print help and exit
  --health       Check task health and exit
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output

Tasks:
  * a.jar:
    - simple-task
  * b.jar:
    - trivial-task
EOE

scenario "Long option help" \
    given_jar a.jar with_tasks 'simple-task' \
        also_jar b.jar with_tasks 'trivial-task' \
    when_run '--help' \
    then_expect <<'EOE'
Usage: ./run-java.sh [-J-jvm_flag ...][-h|--help][--health][-n|--dry-run][-v|--verbose] [--] [-task_flag ...] [task_arg ...]

Flags:
  -J-*           JVM flags prefixed with J
  -h, --help     Print help and exit
  --health       Check task health and exit
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output

Tasks:
  * a.jar:
    - simple-task
  * b.jar:
    - trivial-task
EOE

scenario "Complext tasks help" \
    given_jar a.jar with_tasks 'complex-task -Dfile=$1 $2' \
    when_run '--help' \
    then_expect <<'EOE'
Usage: ./run-java.sh [-J-jvm_flag ...][-h|--help][--health][-n|--dry-run][-v|--verbose] [--] [-task_flag ...] [task_arg ...]

Flags:
  -J-*           JVM flags prefixed with J
  -h, --help     Print help and exit
  --health       Check task health and exit
  -n, --dry-run  Do nothing (dry run); echo actions
  -v, --verbose  Verbose output

Tasks:
  * a.jar:
    - complex-task <file> $2
EOE
