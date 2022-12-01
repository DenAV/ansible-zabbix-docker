Zabbix Installation from containers with Ansible
================================================

Pre-requisites
--------------

* You must have [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your computer.

```shell

# for Debian
sudo apt update
sudo apt install ansible -y

```

Role Variables
--------------
For role Install Docker
- `docker_users: [ubuntu]` - A list of users who will be added to the docker group.

See the [`defaults/main.yml`](https://github.com/DenAV/ansible-zabbix-docker/blob/main/roles/install_docker/defaults/main.yml) file listing 
all possible options which you can be passed to a runner registration command.

For role Install Zabbix Docker
- `must_zbx_server_agent_installed: false` - what should be installed? Zabbix server + agent
- `must_zbx_proxy_agent_installed: false` - what should be installed? Zabbix proxy + agent
- `must_zbx_proxy_installed: false` - what should be installed? Zabbix proxy
- `must_zbx_agent_installed: false` - what should be installed? Zabbix agent

See the [`defaults/main.yml`](https://github.com/DenAV/ansible-zabbix-docker/blob/main/roles/install_zabbix_docker/defaults/main.yml) file listing 
all possible options which you can be passed to a runner registration command.

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
