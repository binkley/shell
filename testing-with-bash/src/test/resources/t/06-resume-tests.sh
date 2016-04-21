# Source me - do not execute

scenario 'Simple job resume' \
    given_jar a.jar with_jobs 'simple-job' \
    when_run -n --resume 'simple-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/a.jar --resume simple-job'

scenario 'Complex job health' \
    given_jar a.jar with_jobs 'complex-job -Dfoo=$1 $2 arg' \
    when_run -n --resume 'complex-job' 'first-arg' 'second-arg' \
    then_exit 0 \
        with_out <<'EOO'
java -Dfoo=first-arg -jar ./lib/a.jar --resume complex-job second-arg arg
EOO
