# Source me - do not execute

scenario 'Bad job name' \
    given_jar some.jar with_jobs 'simple-job' \
    when_run -n 'no-such-job' \
    then_exit 2 \
        with_err <<'EOE'
./run-java.sh: no-such-job: No definition (try -h)
Definitions:
  ./lib/some.jar simple-job
EOE

false && scenario 'Wrong argument count' \
    given_jar some.jar with_jobs 'complex-job $1' \
    when_run -n 'complex-job' \
    then_exit 2 \
        with_err <<'EOE'
./run-java.sh: complex-job: Not enough arguments (try -h)
Definitions:
  ./lib/some.jar complex-job $1
EOE
