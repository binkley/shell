# Source me - do not execute

scenario 'Resumable job' \
    given_project_jar \
    when_run '--resume' 'resumable-job' \
    then_exit 0

scenario 'Unresumable job' \
    given_project_jar \
    when_run '--resume' 'unresumable-job' \
    then_exit 2 \
        with_err 'unresumable-job: Resume not supported'
