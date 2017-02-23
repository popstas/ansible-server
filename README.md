# Attention
This repository don't supported.

I recommend to follow in https://github.com/viasite-ansible and use roles with test badges.

New `ansible-server` will be available at https://github.com/viasite-ansible/ansible-server, but at this time I cannot share it in open source.

This repository worked well at begin of 2016, but it have many limitations:

- not all roles idempotent
- roles not tested with ci
- roles not imdependent
- very big `common` role
- it worked for Ubuntu 14.04, not for 16.04
- it not leverages Ansible 2.x features
- it has only one playbook and relies on tags limit
- test framework custom written on bash
- variables has not scopes


# Install
```
cd /usr/local/src
git clone https://github.com/popstas/ansible-server
cd /usr/local/src/ansible-server
git submodule update --init --recursive
```

or

```
git clone --recursive https://github.com/popstas/ansible-server /usr/local/src/ansible-server
```


## Update submodule
```
pushd roles/rolename
git pull origin master
popd
git commit -m "update roles/rolename fork"
```

## Remove submodule
```
git rm path/to/submodule
git commit
rm -rf .git/modules/path/to/submodule
```


# Playbooks
- server.yml - setup production server
- dev-server.yml - setup develop server



# Vars
- vars/main.yml - все основные переменные, должны быть общими для всех хостов
- vars/private.yml - пароли в явном виде, этот файл нельзя коммитить, использовать только для тестов!
- vars/crypted.yml - пароли в зашифрованном виде, можно коммитить
- .vault_pass.txt - пароль от зашифрованного файла, нельзя коммитить



# Files
- place ssh public keys to vars/ssh-public-keys or change `{{ ssh_public_keys_dir }}` in vars/main.yml
- place ssh public keys to vars/ssh-public-keys-removed or change `{{ ssh_public_keys_removed_dir }}` in vars/main.yml



# Lint rules
Directory `rules` contains some custom ansible-lint rules. 
Command for apply rules:
```
ansible-lint -r rules server.yml
```


## Зашифровать файл:
```
cp vars/private.yml vars/crypted.yml && ansible-vault encrypt --vault-password-file .vault_pass.txt vars/crypted.yml
```

Подробнее о работе с зашифрованным файлом - http://docs.ansible.com/ansible/playbooks_vault.html



# Tests
test.sh - предназначен для запуска тестов на чистой машине, vagrant или docker.
- проверяет синтаксис
- прогоняет через ansible-lint
- запускает server.yml
- проверяет идемпотентность
Не для Teamcity!


## Как тестировать
1. Пишем роль
2. Запускаем инициализацию машины, `tests/docker-init.sh` или `tests/vagrant-init.sh` рекомендуется в vagrant
3. Запускаем тесты в машине
```
tests/test.sh --tags имя_роли
```
4. Если есть ошибки, исправляем


## Vagrant
`tests/vagrant-init.sh` - инициализирует vagrant box и готовит конфиги для запуска в нем ansible

```
tests/vagrant-init.sh
```

```
VM_IP=192.168.1.100 VM_NAME=ansible-server-public tests/vagrant-init.sh
```

## Docker
`tests/docker-init.sh` - создание/запуск докера с --name ansible_server (можно передать имя параметром),
Прописывание данных докера в build/hosts_docker
```
tests/docker-init.sh
```

```
tests/docker-tests.sh ansible-server-2
```


## Teamcity
На Teamcity делается то же самое, что и в test.sh, но в шагах teamcity, чтобы собрался красивый ansible log.
Для удобной сводки написан скрипт `tests/teamcity_ansible_report.sh`, он запускается последним шагом,
переключает статус сборки в зависимости от результатов последнего прогона ansible-playbook.
`ansible-lint` в данный момент (22.11.2015) отключен, до тех пор, пока не будут поправлены зависимые репозитории.



# Ссылки
https://github.com/willthames/ansible-lint - линтер, обязательно пользоваться!
https://github.com/nickjj/rolespec - RoleSpec, фреймворк для автотестов ansible ролей, заточен под DebOps, предполагается, что тесты - отдельный репозиторий
https://github.com/debops/test-suite - RoleSpec тесты от DebOps 
https://github.com/ansible/ansible/issues/12817 - ansible & vagrant ssh connection



# Новые роли и правка существующих
В начале смотреть похожее в ansible galaxy и на github.
Хорошие примеры:
- http://debops.org/
- https://github.com/jdauphant/ansible-roles - у него хорошие стандарты написания ролей
- https://github.com/jdauphant/awesome-ansible - сборник ссылок от него же
- https://github.com/ansible/ansible-examples - официальные примеры
- https://github.com/M4nu/ansible
- https://github.com/Oefenweb, https://oefenweb.github.io/



# Roles

## apache-php
Install apache2 and php5 with modules

## common
Install common packages 

## mysql
- install percona
- install pt-kill

## nginx
Связан с ролями apache-php, site
В /etc/nginx/conf.server.d/000-settings-upstream прописывается путь к apache
Также в /etc/nginx/conf.server.d/ лежат все инклюды для каждого хоста, они прописаны в /roles/site/templates/nginx.conf.j2



# TODO
- [x] common: timezone
- [x] common: scripts from /root/bin and /usr/local/bin
- [x] phpmyadmin
- [x] root cron
- [x] firewall (ufw) - http://docs.ansible.com/ufw_module.html
- [x] add "This file is managed by Ansible, all changes will be lost" to configs, as github.com/debops/debops
- [x] freeze versions of docker and git repositories
- [ ] all: rename sitedir to site_dir and so on
- [ ] заменить latest на present
- [ ] правило для ansible-lint, чтобы проверять, стоит ли тег роли у каждой задачи
- [ ] Проставить теги во все таски
- [ ] Уникальные для серверов переменные и общие для всех наших серверов переменные нужно разделить
- [ ] Install [docker-compose](https://docs.docker.com/compose/install/)
- [ ] https://github.com/angstwad/docker.ubuntu
- [ ] exim dkim

## nginx role issues
- [ ] nginx snippets - https://github.com/jdauphant/ansible-role-nginx/pull/33
- [ ] nginx access rules - https://github.com/jdauphant/ansible-role-nginx/pull/73
- [ ] How to use this role as a dependency ? - https://github.com/jdauphant/ansible-role-nginx/issues/63
