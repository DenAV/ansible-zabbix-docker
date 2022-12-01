## Zabbix Installation from containers with Ansible

## Pre-requisites

* You must have [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your computer.

```shell

# for Debian
sudo apt update
sudo apt install ansible -y

```

## Quick start

Config the Web-Server with Ansible:

Ansible code one that deploys everything you need to run service - docker and related.
```shell
git clone https://github.com/DenAV/ansible-zabbix-docker.git

cd ansible-zabbix-docker
ansible-playbook playbooks/pl_zbx_docker_setup_local.yml -bK
<sudo password>:

or 

sudo ansible-playbook playbooks/pl_zbx_docker_setup_local.yml
```