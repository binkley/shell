# Source me - do not execute

scenario 'Bad job name' \
    given_jar some.jar with_jobs 'simple-job' \
    when_run -n 'no-such-job' \
    then_exit 2 \
        with_err <<'EOE'
./run-java.sh: No definition for job: no-such-job (try -h)
Definitions:
  ./lib/some.jar simple-job
EOE
