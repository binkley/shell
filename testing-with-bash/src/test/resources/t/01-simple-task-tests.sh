# Source me - do not execute

scenario "Simple job in simple jar" \
    given_jar some.jar with_jobs 'simple-job' \
    when_run -n 'simple-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/some.jar simple-job'

scenario "Simple job in complex jar" \
    given_jar some.jar with_jobs <<'EOT' \
    when_run -n 'simple-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/some.jar simple-job'
simple-job
complex-job -flag -Dfile=$1
EOT

scenario "Simple job in simple jar of multiple" \
    given_jar a.jar with_jobs 'simple-job' \
        also_jar b.jar with_jobs 'complex-job -flag -Dfile=$1' \
    when_run -n 'simple-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/a.jar simple-job'
