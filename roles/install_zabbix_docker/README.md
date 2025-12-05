Install Zabbix (Docker) Role
============================

This role deploys Zabbix components (server, proxy, web, web-service, agent) using Docker Compose on Debian/Ubuntu hosts. It supports Zabbix 7.4.5, generates TLS PSK secrets, and can register/update hosts via the Zabbix API.

Requirements
------------

- Ansible >= 2.10
- Docker Engine + Compose v2 (via `docker compose`)
- Target OS: Ubuntu 24.04 LTS (also Debian 11/12) with systemd
- Become (sudo) privileges on the target machine
- Internet access to pull Zabbix and DB images

Role Variables
--------------

Key variables (see `defaults/main.yml` for full list):

- `zabbix_version`: default `7.4.5`; Zabbix release used for images.
- `zabbix_image_flavor`: `alpine` (default) or `ubuntu`.
- `zabbix_image_tag`: composed tag `{{ zabbix_image_flavor }}-{{ zabbix_version }}`.
- `zabbix_deployment_mode`: one of `server_agent`, `proxy_agent`, `proxy`, `agent`.
- `zabbix_server_image`, `zabbix_proxy_image`, `zabbix_web_server_image`, `zabbix_web_service_image`, `zabbix_agent_image`: image names (repository prefix `zabbix/` is applied in templates).
- `mysql_server_image`: default `mysql:8.0-oracle` (adjust if needed).
- `zbx_docker_compose_file`: output compose file name (default `docker-compose.yml`).
- `zbx_container_state`: desired compose state (`present` or `absent`).

Security & networking:
- `zabbix_agent_privileged`: default `false`; avoid privileged unless required.
- `zabbix_agent_pid_host`: default `false`; disable host PID namespace by default.
- `zabbix_agent_network_mode_host`: default `false`; avoid host networking by default.
- `zabbix_agent_cap_add`: list of extra capabilities to grant to agent (optional).
- `zbx_agent_source_ip`, `zbx_agent_listen_ip`: optional IPs to use when agent runs with host networking; if unset but `zabbix_agent_network_mode_host: true`, defaults to the host's `ansible_default_ipv4.address`.
- `zabbix_proxy_network_mode_host`: default `false`; host networking toggle for proxy.
- `zbx_proxy_source_ip`, `zbx_proxy_listen_ip`: optional IPs to use when proxy runs with host networking; if unset but `zabbix_proxy_network_mode_host: true`, defaults to the host's `ansible_default_ipv4.address`.
- `zbx_net_frontend_subnet`: default `172.30.238.0/24`.
- `zbx_net_backend_subnet`: default `172.30.239.0/24`.
- `zabbix_enable_healthchecks`: default `true`; adds simple healthchecks to agent and can be extended to other services.

API & PSK:
- `zabbix_install_pip_packages`: default `true` (installs `zabbix-api` on localhost).
- `zbx_pskfile_secret`: generated automatically if missing; stored at `{{ zbx_volumes_local_path }}/var/enc/secret.psk`.
- `zabbix_api_create_hostgroup`, `zabbix_api_create_hosts`: booleans controlling API automation.
- `zabbix_agent_tlspsk_secret`, `zabbix_agent_tlspskidentity`: PSK secret and identity used by agent and API updates. By default `zabbix_agent_tlspskidentity` maps to `zbx_agent_psk_identity`.
- `zabbix_api_proxy`: proxy name as it exists in the Zabbix server, used when registering hosts via API (defaults to `zbx_proxy_hostname`).

Behavior Overview
-----------------

- Renders environment files for selected deployment mode and builds a Docker Compose file from templates.
- Uses dynamic image tags like `zabbix/zabbix-server-mysql:{{ zabbix_image_tag }}`.
- Creates a PSK file if missing and sets secure permissions.
- Starts services with `docker compose` via the Ansible Docker collection.
- Optionally registers/updates hosts in Zabbix using API calls once services are up.

Security Hardening
------------------

- Agent container runs without `privileged`, `pid: host`, or `network_mode: host` by default; enable only when necessary.
- Configure capabilities via `zabbix_agent_cap_add` (e.g., `SYS_PTRACE`, `NET_RAW`) rather than full privilege.
- Parameterize network subnets to avoid collisions on busy hosts.
- Consider moving Zabbix API credentials and PSK secrets to Ansible Vault.
- Add resource limits and healthchecks for server/proxy if desired.

Example Playbooks
-----------------

Server + Agent on Ubuntu 24.04 with Zabbix 7.4.5 (alpine):

```yaml
- hosts: zabbix
  become: yes
  roles:
    - role: install_zabbix_docker
      vars:
        zabbix_version: "7.4.5"
        zabbix_image_flavor: "alpine"
        zabbix_deployment_mode: "server_agent"
        zabbix_agent_privileged: false
        zabbix_agent_network_mode_host: false
        zabbix_agent_cap_add:
          - NET_RAW
```

Proxy + Agent with custom subnets:

```yaml
- hosts: zbx-proxy
  become: yes
  roles:
    - role: install_zabbix_docker
      vars:
        zabbix_deployment_mode: "proxy_agent"
        zbx_net_frontend_subnet: "10.20.38.0/24"
```

Dependencies
------------

- `community.docker` Ansible collection for Compose tasks.
- Docker Engine with Compose v2 on target host.

Notes
-----

- Templates previously defaulted to 6.x images; now use `zabbix_version` and `zabbix_image_tag`. Ensure the tag exists in Docker Hub.
- If using host networking for agent, review security implications carefully.
- For MySQL tuning/SSL, enable related `ZBX_DBTLS*` variables in `.env_srv` and secrets.

License
-------

BSD

Author Information
------------------

Maintained by the `ansible-zabbix-docker` project. Contributions and issues via repository tracker.
