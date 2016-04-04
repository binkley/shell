# Source me - do not execute

scenario "Simple task in simple jar" \
    given_jar some.jar with_tasks 'simple-task' \
    when_run 'simple-task' \
    then_expect 'java -jar ./lib/some.jar simple-task'

scenario "Simple task in complex jar" \
    given_jar some.jar with_tasks <<'EOT' \
    when_run 'simple-task' \
    then_expect 'java -jar ./lib/some.jar simple-task'
simple-task
complex-task -flag -Dfile=$1
EOT

scenario "Simple task in simple jar of multiple" \
    given_jar a.jar with_tasks 'simple-task' \
        also_jar b.jar with_tasks 'complex-task -flag -Dfile=$1' \
    when_run 'simple-task' \
    then_expect 'java -jar ./lib/a.jar simple-task'
