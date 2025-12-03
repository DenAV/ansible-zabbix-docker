# Ansible Zabbix via Docker

This project installs Zabbix locally using Docker containers via Ansible. It supports multiple deployment variants (server+agent, proxy+agent, proxy-only, agent-only) and targets Zabbix 7.4.5 on Ubuntu 24.04 LTS (and Debian 11/12).

**Components**
- Role `install_docker`: Installs Docker Engine and Compose v2 with best-practice apt keyring.
- Role `install_zabbix_docker`: Generates env files, renders Compose, deploys Zabbix stack, manages TLS PSK, and optionally registers hosts via API.

## Prerequisites

- Ansible >= 2.10 on your control machine
- Target: Ubuntu 24.04 or Debian 11/12 with sudo and internet access
- Docker Engine + Compose v2 on the target (installed by `install_docker` role)

Install Ansible (example for Debian/Ubuntu):

```powershell
sudo apt update
sudo apt install ansible -y
```

## Quick Start (Local Deploy)

```powershell
# Clone the repository
git clone https://github.com/DenAV/ansible-zabbix-docker.git
cd ansible-zabbix-docker

# Server + Agent on localhost
ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml -bK

# Proxy + Agent on localhost
ansible-playbook playbooks/pl_zbx_docker_setup_proxy_agent_local.yml -bK

# Agent only on localhost
ansible-playbook playbooks/pl_zbx_docker_setup_agent_local.yml -bK
```

Tip: Use `sudo ansible-playbook ...` if you prefer not to provide `-K`.

### Production Playbooks Naming

- Playbooks intended for production use are prefixed with `prod-` (e.g., `prod-zbx-server.yml`).
- This helps distinguish production runs from local/test playbooks (`pl_*` examples above).
- Adjust variables, inventory, and vault usage accordingly for production deployments.

## Configuration Overview

- Docker role vars (see `roles/install_docker/README.md`):
	- `docker_package_state`, `docker_compose_plugin_install`, `docker_users`, `docker_daemon_options`, etc.

- Zabbix role vars (see `roles/install_zabbix_docker/README.md`):
	- `zabbix_version` (default `7.4.5`), `zabbix_image_flavor` (`alpine`|`ubuntu`), `zabbix_deployment_mode` (`server_agent`|`proxy_agent`|`proxy`|`agent`)
	- Security: `zabbix_agent_privileged` (default false), `zabbix_agent_cap_add`, `zabbix_agent_network_mode_host`
	- Networks: `zbx_net_frontend_subnet`, `zbx_net_backend_subnet`
	- API & PSK: `zabbix_api_create_hosts`, `zabbix_api_update_psk`, PSK auto-generation

To override variables, pass `-e` or create inventory/group_vars. Example:

```powershell
ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml -bK \
	-e "zabbix_version=7.4.5 zabbix_image_flavor=alpine zabbix_deployment_mode=server_agent"
```

## What Gets Installed

- Server+Agent: Zabbix server, web frontend (nginx), web-service, MySQL, Agent2
- Proxy+Agent: Zabbix proxy (sqlite), Agent2
- Proxy-only: Zabbix proxy (sqlite)
- Agent-only: Agent2

The role renders `.env_*` files and a `docker-compose.yml` in a local project path, then runs `docker compose` to start services. Host registration via API is optional and waits for services to run.

## Best Practices Applied

- Signed-by APT keyring for Docker repository
- Compose v2 plugin (`docker compose`) and modern compose schema
- Parameterized image tags for Zabbix 7.4.5 and OS flavor
- Security defaults: agent not privileged, no host networking unless enabled
- Configurable network subnets to avoid collisions
- Simple healthchecks for agent; extensible to other services

## Troubleshooting

- Ensure Docker + Compose v2 is present (`docker compose version`).
- If images fail to pull, verify `zabbix_version` and `zabbix_image_flavor` exist on Docker Hub.
- For API automation, confirm `zabbix_url`, credentials, and network reachability.
- For a full checklist and ready-to-run commands, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md).

## Next Steps

- See role docs:
	- `roles/install_docker/README.md`
	- `roles/install_zabbix_docker/README.md`
- Customize env templates under `roles/install_zabbix_docker/templates/env_vars/`.

### Using Ansible Vault for credentials

Store sensitive values (Zabbix API user/password, PSK) with Vault:

```powershell
# Create a vault-protected vars file
ansible-vault create group_vars/all/vault.yml
```

Example vault contents:

```yaml
zabbix_api_user: "admin"
zabbix_api_pass: "<secure-password>"
zbx_pskfile_secret: "<64-hex-characters>"
```

Run playbooks with Vault password prompt or file:

```powershell
ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml -bK --ask-vault-pass
# or
ansible-playbook playbooks/pl_zbx_docker_setup_server_agent_local.yml -bK --vault-password-file .vault_pass
```

## License

BSD

## Maintainers

Maintained by the `ansible-zabbix-docker` project. Contributions and issues via repository tracker.
