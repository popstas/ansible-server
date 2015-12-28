#!/bin/bash
PLAYBOOK=${ANSIBLE_PLAYBOOK:-"server.yml"}
NO_LINT=${NO_LINT:-""}
NO_IDEMPOTENCE=${NO_IDEMPOTENCE:-""}
ARGS="--vault-password-file .vault_pass.txt -i build/hosts $@"

set -e

exists (){
	which $1 &> /dev/null
}
if ! exists ansible-lint; then
	echo >&2 "ansible-lint not found, install it:"
	echo >&2 "sudo pip install ansible-lint"
	exit 1
fi

temp=$(mktemp -t ansible-test-XXXX)
trap 'rm -f "$temp"' EXIT

if [ -z "$NO_LINT" ]; then
	ansible-lint $PLAYBOOK
fi

ansible-playbook $PLAYBOOK $ARGS --syntax-check

ansible-playbook $PLAYBOOK $ARGS -vv

if [ -z "$NO_IDEMPOTENCE" ]; then
	ansible-playbook $PLAYBOOK $ARGS | tee $temp && \
	cat $temp | grep -q 'changed=0.*failed=0' \
	&& (echo 'Idempotence test: pass' && exit 0) \
	|| (echo 'Idempotence test: fail' && exit 1)
fi