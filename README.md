# ansible-server


# Playbooks
- server.yml - настраивает сервер

# Vars
- vars/main.yml - все основные переменные, должны быть общими для всех хостов
- vars/private.yml - пароли в явном виде, этот файл нельзя коммитить, использовать только для тестов!
- vars/crypted.yml - пароли в зашифрованном виде, можно коммитить
- .vault_pass.txt - пароль от зашифрованного файла, нельзя коммитить
## Зашифровать файл:
```cp vars/private.yml vars/crypted.yml && ansible-vault encrypt --vault-password-file .vault_pass.txt vars/crypted.yml```

Подробнее о работе с зашифрованным файлом - http://docs.ansible.com/ansible/playbooks_vault.html

# Test
test.sh - предназначен для запуска тестов на чистой машине, vagrant или docker.
- проверяет синтаксис
- прогоняет через ansible-lint
- запускает server.yml
- проверяет идемпотентность

## Как тестировать
1. Пишем роль
2. Запускаем test.sh --tags имя_роли
3. Если есть ошибки, исправляем

https://github.com/willthames/ansible-lint - линтер, обязательно пользоваться!
https://github.com/nickjj/rolespec - RoleSpec, фреймворк для автотестов ansible ролей, заточен под DebOps, предполагается, что тесты - отдельный репозиторий
https://github.com/debops/test-suite - RoleSpec тесты от DebOps 

# Новые роли и правка существующих
В начале смотреть похожее в ansible galaxy и на github.
Хорошие примеры:
- http://debops.org/
- https://github.com/jdauphant/ansible-roles - у него хорошие стандарты написания ролей
- https://github.com/jdauphant/awesome-ansible - сборник ссылок от него же
- https://github.com/ansible/ansible-examples - официальные примеры

## Full recreate VM
```
vagrant destroy -f && vagrant up
```

## Restart VM and provision
```
vagrant halt && vagrant up --provision
```

## Quick provision to vagrant
```
ansible-playbook server.yml --vault-password-file .vault_pass.txt -i hosts --limit vagrant -vv -u root
```


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
