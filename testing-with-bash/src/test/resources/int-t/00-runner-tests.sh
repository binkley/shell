# Source me - do not execute

scenario "Short option help" \
    given_project_jar \
    when_run '-h' \
    then_exit 0 \
        with_out <<'EOO'
Usage: ./run-java.sh [-J-jvm_flag ...][-d|--debug][-h|--help][--health][-j|--jobs][-n|--dry-run][--resume][-v|--verbose] [--] [-job_flag ...] [job_arg ...]

Flags:
  -J-*           JVM flags prefixed with J
  -d, --debug    Print debug output while running
  -h, --help     Print help and exit normally
  --health       Check job health and exit
  -j, --jobs     List jobs and exit normally
  -n, --dry-run  Do nothing (dry run); echo actions
  --resume       Resume previously failed job
  -v, --verbose  Verbose output

Jobs:
  * testing-with-bash-0-SNAPSHOT.jar:
    - healthy-job
    - resumable-job
    - takes-arg-job $1
    - unhealthy-job
    - unresumable-job
EOO


scenario 'Jobs lists project jar' \
    given_project_jar \
    when_run '--jobs' \
    then_exit 0 \
        with_out <<'EOO'
healthy-job
resumable-job
takes-arg-job $1
unhealthy-job
unresumable-job
EOO
