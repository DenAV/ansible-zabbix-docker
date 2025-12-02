# Zabbix Installation from containers with Ansible

This Ansible role installs Zabbix server, proxy or agent from Docker containers.

## Pre-requisites

* You must have [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your computer.

```shell
# for Debian
sudo apt update
sudo apt install ansible -y
```

## Role Variables

The following variables are available for role Install Docker

- `docker_users: [ubuntu]` - list of users to be added to docker group

The following variables are available for role Install Zabbix Docker

- `must_zbx_server_agent_installed: false` - what should be installed? Zabbix server + agent
- `must_zbx_proxy_agent_installed: false` - what should be installed? Zabbix proxy + agent
- `must_zbx_proxy_installed: false` - what should be installed? Zabbix proxy
- `must_zbx_agent_installed: false` - what should be installed? Zabbix agent

See the [`defaults/main.yml`](https://github.com/DenAV/ansible-zabbix-docker/blob/main/roles/install_docker/defaults/main.yml) file listing all possible options which you can be passed to a runner registration command.

## Quick start

The following commands will get you up and running quickly:

```shell
# Clone the repository
git clone https://github.com/DenAV/ansible-zabbix-docker.git

cd ansible-zabbix-docker

# Run Ansible playbook to install Zabbix server + agent in Docker containers on localhost
ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml -bK
<sudo password>:

or 
    
sudo ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml
```
