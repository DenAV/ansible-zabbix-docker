Install Docker Role
===================

This role installs and configures Docker Engine on Debian/Ubuntu hosts, sets up the official Docker APT repository, installs Docker packages, and optionally configures daemon options and adds users to the `docker` group. It also ensures the Docker service is enabled and running.

Requirements
------------

- Ansible >= 2.10
- Target OS: Debian 11/12 or Ubuntu 20.04/22.04 (systemd-based)
- Python on the target host
- Become (sudo) privileges for package installation and service management
- Internet access to reach Docker APT repositories

Role Variables
--------------

Defined in `defaults/main.yml`:

- `docker_service_manage` (bool, default: `true`): Whether to manage the Docker service state.
- `docker_service_state` (string, default: `started`): Desired service state.
- `docker_service_enabled` (bool, default: `true`): Enable Docker at boot.
- `docker_restart_handler_state` (string, default: `restarted`): State used by the restart handler.
- `docker_repo_url` (string, default: `https://download.docker.com/linux`): Base URL for Docker repo and GPG key.
- `docker_keyring_path` (string, default: `/etc/apt/keyrings/docker.gpg`): Location of the APT signed-by keyring.
- `docker_apt_release_channel` (string, default: `stable`): Release channel for APT repo (`stable` or `nightly`).
- `docker_apt_repository` (string): Docker APT repository line; templated from distro and release.
- `docker_apt_ignore_key_error` (bool, default: `true`): Ignore errors when adding the Docker apt key.
- `docker_apt_gpg_key` (string): URL to Docker GPG key; templated from distro.
- `docker_users` (list, default: `[ubuntu]`): Users to add to the `docker` group.
- `docker_daemon_options` (dict, default: `{}`): Content to render into `/etc/docker/daemon.json` when non-empty.
- `docker_package_state` (string, default: `present`): Package state for installs (`present` or `latest`).
- `docker_compose_plugin_install` (bool, default: `true`): Whether to install the Compose v2 plugin.
- `zabbix_gid` (int, default: `1995`), `zabbix_uid` (int, default: `1997`): IDs used for the `zabbix` group/user.

Behavior Overview
-----------------

- Removes any legacy Docker packages (`docker`, `docker-engine`, `docker.io`, `containerd`, `runc`).
- Installs apt prerequisites (`apt-transport-https`, `ca-certificates`, `lsb-release`, `curl`, `gnupg`).
- Adds the official Docker GPG key and APT repository.
- Uses a dedicated APT keyring with `signed-by` for repository validation.
- Installs packages: `docker-ce`, `docker-ce-cli`, `containerd.io`, and (optionally) `docker-compose-plugin` for Compose v2 (`docker compose`).
- Optionally writes `/etc/docker/daemon.json` from `docker_daemon_options`.
- Starts and enables the `docker` service (if `docker_service_manage` is true).
- Adds listed `docker_users` to the `docker` group; resets SSH connection to apply group membership.
- Creates a `zabbix` group (gid 1995) and user (uid 1997, shell `/sbin/nologin`) used by the broader project.
  - These IDs are configurable via `zabbix_gid` and `zabbix_uid`.

Handlers
--------

- `restart docker`: Restarts the Docker service using `docker_restart_handler_state` when configuration or package changes occur.

Dependencies
------------

None.

Example Playbooks
-----------------

Install Docker with default settings and add an extra user to the `docker` group:

```yaml
- hosts: all
  become: yes
  roles:
    - role: install_docker
      vars:
        docker_users:
          - ubuntu
          - myuser
```

Configure Docker daemon logging and ensure service management is enabled:

```yaml
- hosts: docker_hosts
  become: yes
  roles:
    - role: install_docker
      vars:
        docker_daemon_options:
          log-driver: "json-file"
          log-opts:
            max-size: "100m"
            max-file: "3"
        docker_service_manage: true
```

Pin to the nightly APT channel (advanced):

```yaml
- hosts: lab
  become: yes
  roles:
    - role: install_docker
      vars:
        docker_apt_release_channel: nightly
```

Notes
-----

- This role currently targets Debian-family distributions; the `install_docker.yml` tasks run only when `ansible_os_family == 'Debian'`.
- Compose v2 is provided by `docker-compose-plugin`; use `docker compose ...` instead of `docker-compose`.
- When `docker_daemon_options` is empty, `/etc/docker/daemon.json` is not created.
- Group membership changes require a new login session; the role performs an SSH connection reset automatically.

License
-------

BSD

Author Information
------------------

Maintained by the `ansible-zabbix-docker` project. For issues and contributions, please use the repository's issue tracker.
