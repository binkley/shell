# Source me - do not execute

scenario "Complex job in simple jar" \
    given_jar some.jar with_jobs 'complex-job -flag -Dfile=$1 $2 arg' \
    when_run 'complex-job' /tmp/data 'some-token' \
    then_expect <<'EOE'
java -Dfile=/tmp/data -jar ./lib/some.jar complex-job -flag some-token arg
EOE
