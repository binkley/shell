# Source me - do not execute

scenario 'Resumable job' \
    given_jar testing-bash-${project.version}.jar \
    when_run '--resume' 'resumable-job' \
    then_exit 0   # and_no_output

scenario 'Unresumable job' \
    given_jar testing-bash-${project.version}.jar \
    when_run '--resume' 'unresumable-job' \
    then_exit 2   # and_no_output
