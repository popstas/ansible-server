#!/bin/bash

temp_dir="$1"

last_log=$(find "$temp_dir/ansible-run" \
 -name "ansible-run-raw-RUNNER_*" -printf '%T@ %p\n' \
 | sort -n | tail -n1 | awk '{print $2}')

summary=$(grep -o "ok=.*" "$last_log")
changed_oneline=""

get_value () {
	echo "$summary" | grep -o "$1=[0-9]*" | cut -d'=' -f2
}

get_by_state () {
	state="$1"
	if [ "$state" = "changed" ]; then
		unfiltered=$(grep -B6 'changed": true' "$last_log" | grep "TASK\|changed" | cut -d'|' -f2-)

		tasks=$(echo "$unfiltered" | awk 'NR % 2 == 1' \
		| sed 's/TASK: \[//g' \
		| sed 's/\] *.*//g')

		msg=$(echo "$unfiltered" | awk 'NR % 2 == 0' \
		| sed 's/.*"msg": "//g' \
		| sed 's/",.*//g' \
		| sed 's/\\n/|n/g')

		IFS=$'\n'
		for task in $tasks; do
			tc_msg "message text='$task' status='WARNING'"
			if [ -z "$changed_oneline" ]; then changed_oneline=", changed:"; fi
			changed_oneline="$changed_oneline|n$task"
		done
	fi
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
  get_by_state changed
  status="FAILURE"
fi

if [ "$failed" != 0 ]; then
  tc_msg "message text='$failed failed' status='ERROR'"
  status="FAILURE"
fi

tc_msg "buildStatus status='$status' text='$summary|n$changed_oneline'"
