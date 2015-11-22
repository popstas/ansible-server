#!/usr/bin/env bash
# create ssh key if not exists

set -e

[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P ""

name="${1:-"ansible_server"}"

export VM_NAME="$name"

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
sed -i "s|private_key_file.*|private_key_file=$private_key_file|g" ansible.cfg
