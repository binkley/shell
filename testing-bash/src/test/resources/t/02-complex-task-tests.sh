# Source me - do not execute

scenario "Complex task in simple jar" \
    given_jar some.jar with_tasks 'complex-task -flag -Dfile=$1 $2 arg' \
    when_run 'complex-task' /tmp/data 'some-token' \
    then_expect <<'EOE'
java -Dfile=/tmp/data -jar ./lib/some.jar complex-task -flag some-token arg
EOE
