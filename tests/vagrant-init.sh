#!/usr/bin/env bash
# create ssh key if not exists

set -e
# [ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P ""

export VM_NAME=${VM_NAME:-"ansible-server"}
echo "export VM_NAME='$VM_NAME'"

VM_IP=${VM_IP:-""}
if [ -n "$VM_IP" ]; then
	export VM_IP="$VM_IP"
	echo "export VM_IP='$VM_IP'"
else
	unset VM_IP
	echo "unset VM_IP"
fi


#export ANSIBLE_HOST_KEY_CHECKING=False # http://docs.ansible.com/ansible/intro_getting_started.html#host-key-checking

vagrant up --no-provision

ssh_config=$(vagrant ssh-config)
ssh_config_get (){
	echo "$ssh_config" | grep "$1" | awk '{print $2}'
}

port=$(ssh_config_get Port)
private_key_file=$(ssh_config_get IdentityFile)

echo "add host to inventory"
mkdir -p build

vagrant ssh-config > build/ssh-config
echo localhost:$port > build/hosts

echo "add private_key_file to ansible.cfg"
if [ ! -f "ansible.cfg" ]; then
	echo -e "[defaults]\nhost_key_checking = false\nremote_user=vagrant\n\nprivate_key_file=\n" > ansible.cfg
fi
sed -i "s|private_key_file.*|private_key_file=$private_key_file|g" ansible.cfg
