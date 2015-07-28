# ansible-aws
Ansible playbook for setup free t2.micro for site hosting.
ansible-playbook -i hosts setup_aws.yml

Полученный IP адрес инстанса записать в файл hosts, в секцию test

Чтобы использовать ключ без проблем, нужно использовать ssh-agent, вот так:
1. Инициализируем агент, надо делать для каждой ssh-сессии
2. По умолчанию агент знает только приватный ключ текущего юзера. Добавляем в него нужный ключ:

```eval $(ssh-agent) && ssh-add ~/.ssh/popstas-aws.pem```

Сессия кончится через какое-то время.

# Playbooks
- server.yml - настраивает сервер
- sites.yml - настраивает сайты на нем

# Добавление сайта
1. Скопировать sites/_template.yml в sites/имя_юзера.yml
2. Добавить в sites.yml роль: ```- { role: site, vars_file: sites/имя_юзера.yml }```
3. Запустить плейбук: ```ansible-playbook sites.yml --vault-password-file .vault_pass.txt -i hosts --limit vagrant -v```

# Vars
- vars/main.yml - все основные переменные, должны быть общими для всех хостов
- vars/private.yml - пароли в явном виде, этот файл нельзя коммитить, использовать только для тестов!
- vars/crypted.yml - пароли в зашифрованном виде, можно коммитить
- .vault_pass.txt - пароль от зашифрованного файла, нельзя коммитить
- sites/*.yml - настройки отдельных сайтов
## Зашифровать файл:
```cp vars/private.yml vars/crypted.yml && ansible-vault encrypt --vault-password-file .vault_pass.txt vars/crypted.yml```

Подробнее о работе с зашифрованным файлом - http://docs.ansible.com/ansible/playbooks_vault.html

# Test
1. Пишем роль
2. Редактируем test.yml, комментим все роли, кроме нужной
3. В роли тоже можно закомментить уже проверенное, если роль большая.
4. Запускаем
```
ansible-playbook -i hosts test.yml -vv
```
5. Если есть ошибки, исправляем.
6. Если ошибок нет, запустить еще раз, не должно быть ни одного changed

https://github.com/willthames/ansible-lint - линтер, обязательно пользоваться!
https://github.com/nickjj/rolespec - RoleSpec, фреймворк для автотестов ansible ролей
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
ansible-playbook playbook.yml -i hosts --limit vagrant -vv -u root
```

# Roles

## apache-php
Install apache2 and php5 with modules

## common
Install common packages 

## mysql
Install percona with config from template, set up root password

## nginx
Связан с ролями apache-php, site
В /etc/nginx/conf.server.d/000-settings-upstream прописывается путь к apache
Также в /etc/nginx/conf.server.d/ лежат все инклюды для каждого хоста, они прописаны в /roles/site/templates/nginx.conf.j2

# TODO
[x] common: timezone
[x] common: scripts from /root/bin and /usr/local/bin
[ ] all: rename sitedir to site_dir and so on
[x] phpmyadmin
[x] root cron
[x] firewall (ufw) - http://docs.ansible.com/ufw_module.html
[x] add "This file is managed by Ansible, all changes will be lost" to configs, as github.com/debops/debops
[x] freeze versions of docker and git repositories
[ ] заменить latest на present
[ ] Проставить теги во все таски
[ ] Уникальные для серверов переменные и общие для всех наших серверов переменные нужно разделить
