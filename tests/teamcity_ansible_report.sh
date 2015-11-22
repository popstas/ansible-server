#!/bin/bash

last_log=$(find "%system.teamcity.build.tempDir%/ansible-run" \
 -name "ansible-run-raw-RUNNER_*" -printf '%T@ %p\n' \
 | sort -n | tail -n1 | awk '{print $2}')

summary=$(grep -o "ok=.*" "$last_log")

get_value () {
  echo "$summary" | grep -o "$1=[0-9]*" | cut -d'=' -f2
}

tc_msg () {
  echo "##teamcity[$@]"
}

ok=$(get_value ok)
changed=$(get_value changed)
failed=$(get_value failed)

status="SUCCESS"

if [ "$ok" != 0 ]; then
  tc_msg "message text='$ok ok' status='NORMAL'"
fi

if [ "$changed" != 0 ]; then
  tc_msg "message text='$changed changed' status='WARNING'"
  status="FAILURE"
fi

if [ "$failed" != 0 ]; then
  tc_msg "message text='$failed failed' status='ERROR'"
  status="FAILURE"
fi

tc_msg "buildStatus status='$status' text='$summary'"
