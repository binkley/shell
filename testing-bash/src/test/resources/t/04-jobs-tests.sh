# Source me - do not execute

scenario "Short option jobs" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '-j' \
    then_exit 0 \
        with_out <<'EOO'
simple-job
trivial-job
EOO

scenario "Long option jobs" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '--jobs' \
    then_exit 0 \
        with_out <<'EOO'
simple-job
trivial-job
EOO

scenario "Complex jobs help" \
    given_jar a.jar with_jobs 'complex-job -Dfile=$1 $2' \
    when_run '--jobs' \
    then_exit 0 \
        with_out <<'EOO'
complex-job -Dfile=$1 $2
EOO
