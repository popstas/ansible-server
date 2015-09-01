#!/usr/bin/env bash
# create ssh key if not exists
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -P ""

name="${1:-"ansible_server"}"

# run docker
docker run --name $name -d \
 -v /var/cache/apt:/var/cache/apt -P \
 -e AUTHORIZED_KEYS="$(cat ~/.ssh/id_rsa.pub)" tutum/ubuntu:trusty ||
docker start %system.teamcity.buildType.id%

port=$(docker port $name 22 | cut -d':' -f2)

# add docker host to known_hosts
# http://askubuntu.com/questions/123072/ssh-automatically-accept-keys
ssh root@localhost -p $port -o StrictHostKeyChecking=no true

# add host to inventory
mkdir -p build
echo localhost:$port > build/hosts_docker
