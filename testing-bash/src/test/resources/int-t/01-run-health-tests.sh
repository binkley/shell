# Source me - do not execute

scenario 'Run job health' \
    given_jar testing-bash-${project.version}.jar \
    when_run '--health' 'real-job' \
    then_exit 0   # and_no_output
