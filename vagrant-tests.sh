#!/usr/bin/env bash
# create ssh key if not exists

set -e

[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P ""

name="${1:-"ansible_server"}"

export BOX_NAME="$name"

# run docker
vagrant up

# add docker host to known_hosts
# http://askubuntu.com/questions/123072/ssh-automatically-accept-keys
ssh root@localhost -p $port -o StrictHostKeyChecking=no true

ssh_config=$(vagrant ssh-config)

# add host to inventory
mkdir -p build

echo localhost:$port > build/hosts_vagrant
