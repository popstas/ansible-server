# ansible-aws
Ansible playbook for setup free t2.micro for site hosting.

# Test

## Full recreate VM
```
cd tests
vagrant destroy -f && vagrant up
```

## Restart VM and provision
```
cd tests
vagrant halt && vagrant up --provision
```


# Roles

## apache-php
Install apache2 and php5 with modules

## common
Install common packages 

## mysql
Install percona with config from template, set up root password



# TODO
[ ] common: timezone
