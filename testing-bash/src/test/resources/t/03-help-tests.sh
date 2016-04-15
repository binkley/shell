# Source me - do not execute

scenario "Short option help" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '-h' \
    then_expect <<'EOE'
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
  * a.jar:
    - simple-job
  * b.jar:
    - trivial-job
EOE

scenario "Long option help" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '--help' \
    then_expect <<'EOE'
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
  * a.jar:
    - simple-job
  * b.jar:
    - trivial-job
EOE

scenario "Complext jobs help" \
    given_jar a.jar with_jobs 'complex-job -Dfile=$1 $2' \
    when_run '--help' \
    then_expect <<'EOE'
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
  * a.jar:
    - complex-job <file> $2
EOE
