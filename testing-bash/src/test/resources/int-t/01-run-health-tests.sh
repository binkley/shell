# Source me - do not execute

scenario 'Healthy job' \
    given_jar testing-bash-${project.version}.jar \
    when_run '--health' 'healthy-job' \
    then_exit 0   # and_no_output

scenario 'Unhealthy job' \
    given_jar testing-bash-${project.version}.jar \
    when_run '--health' 'unhealthy-job' \
    then_exit 1 \
        with_err 'unhealthy-job: I am sad'
