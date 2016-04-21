# Source me - do not execute

scenario 'Simple job health' \
    given_jar a.jar with_jobs 'simple-job' \
    when_run -n --health 'simple-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/a.jar --health simple-job'

scenario 'Complex job health' \
    given_jar a.jar with_jobs 'complex-job -Dfoo=$1 $2 arg' \
    when_run -n --health 'complex-job' \
    then_exit 0 \
        with_out 'java -jar ./lib/a.jar --health complex-job'
