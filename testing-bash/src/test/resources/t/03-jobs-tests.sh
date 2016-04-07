# Source me - do not execute

scenario "Short option jobs" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '-j' \
    then_expect <<'EOE'
simple-job
trivial-job
EOE

scenario "Long option jobs" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'trivial-job' \
    when_run '--jobs' \
    then_expect <<'EOE'
simple-job
trivial-job
EOE

scenario "Complex jobs help" \
    given_jar a.jar with_jobs 'complex-job -Dfile=$1 $2' \
    when_run '--jobs' \
    then_expect <<'EOE'
complex-job -Dfile=$1 $2
EOE
