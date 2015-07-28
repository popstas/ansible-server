#!/bin/bash
PLAYBOOK="server.yml"
ARGS="--vault-password-file .vault_pass.txt $@"

temp=$(mktemp -t ansible-test-XXXX)
trap 'rm -f "$temp"' EXIT

ansible-lint $PLAYBOOK && \
ansible-playbook $PLAYBOOK $ARGS --syntax-check && \
ansible-playbook $PLAYBOOK $ARGS --connection=local -vvvv && \
ansible-playbook $PLAYBOOK $ARGS --connection=local | tee $temp
cat $temp | grep -q 'changed=0.*failed=0' \
	&& (echo 'Idempotence test: pass' && exit 0) \
	|| (echo 'Idempotence test: fail' && exit 1)
