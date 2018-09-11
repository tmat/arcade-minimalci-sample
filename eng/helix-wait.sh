#!/bin/bash
# Script for checking on Helix job periodically
export PYTHONIOENCODING=utf8
finished=0
workItems=""

while [ $finished -lt $NumberOfWorkItems ]
do
  workItems=$(curl --header "Accept: application/json" "https://helix.dot.net/api/2018-03-14/aggregate/workitems?groupBy=job.build&filter.name=${HelixJobId}&access_token=${HelixAccessToken}")

  pass=$(python parsejson.py $workItems 'Data' 'WorkItemStatus' 'pass')
  fail=$(python parsejson.py $workItems 'Data' 'WorkItemStatus' 'fail')
  finished=$(( $pass + $fail ))

  echo "$finished work items finished out of $NumberOfWorkItems total work items."

  sleep 10
done

buildId=$(python parsejson.py $workItems 'Key' 'job.build')
fail=$(python parsejson.py $workItems 'Data' 'WorkItemStatus' 'fail')
none=$(python parsejson.py $workItems 'Data' 'WorkItemStatus' 'none')

testfail=$(python parsejson.py $workItems 'Data' 'Analysis' 'Status' 'fail')
testpass=$(( $(python parsejson.py $workItems 'Data' 'Analysis' 'Status' 'pass') + $(python parsejson.py $workItems 'Data' 'Analysis' 'Status' 'passonretry') ))
testskip=$(python parsejson.py $workItems 'Data' 'Analysis' 'Status' 'skip')

if [ $fail -gt 0 ] || [ $none -gt 0 ]; then
  echo "##vso[task.logissue type=error;]Some work items failed catastrophically failed -- see https://mc.dot.net/#/user/jonfortescue/pr~2Fcoreclr~2Fmaster/test~2Fstuff/${buildId}"
  echo "##vso[task.complete result=Failed;]FAILED"
  exit 1
elif [ $testfail -gt 0 ]; then
  echo "##vso[task.logissue type=error;]${testfail} tests failed -- see https://mc.dot.net/#/user/jonfortescue/pr~2Fcoreclr~2Fmaster/test~2Fstuff/${buildId}"
  echo "##vso[task.complete result=Failed;]FAILED"
  exit 1
else
  echo "${testpass} tests passed; ${testskip} tests skipped."
fi
