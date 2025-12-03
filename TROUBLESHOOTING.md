# Troubleshooting: Ansible Zabbix via Docker

Use this checklist to validate Docker/Compose setup, containers, networking, and Zabbix agent/proxy configuration.

## Quick Status
- Compose config: `cd /zabbix && sudo docker compose config`
- Services list: `sudo docker compose ps`
- Logs (last 200):
  - Agent: `sudo docker logs zabbix-agent --tail=200`
  - Proxy: `sudo docker logs zabbix-proxy --tail=200`
  - Server: `sudo docker logs zabbix-server --tail=200`

## Images & Recreate
- Pull images: `sudo docker compose pull`
- Up/refresh: `sudo docker compose up -d --pull=always`
- Stop/remove: `sudo docker compose down`

## Health & Ports
- Agent port: `timeout 1 bash -c '</dev/tcp/127.0.0.1/10050' && echo OK || echo FAIL`
- Proxy port: `timeout 1 bash -c '</dev/tcp/127.0.0.1/10051' && echo OK || echo FAIL`
- Server port: `timeout 1 bash -c '</dev/tcp/127.0.0.1/10051' && echo OK || echo WAIT`

## Networks
- List networks: `sudo docker network ls`
- Inspect frontend: `sudo docker network inspect zbx_net_frontend | jq '.[0].IPAM.Config'`
- Container DNS reachability:
  - `sudo docker exec zabbix-agent ping -c1 zabbix-proxy`
  - `sudo docker exec zabbix-proxy getent hosts zabbix-server`

## Agent Configuration
- Environment applied: `sudo docker exec zabbix-agent env | grep ZBX_`
- PSK secret file: `sudo docker exec zabbix-agent cat /var/lib/zabbix/enc/secret.psk`
- Identity (from env): check `cat /zabbix/env_vars/.env_agent` for `ZBX_TLSPSKIDENTITY`
- Increase logging temporarily:
  - `sudo docker exec zabbix-agent zabbix_agentd -R log_level_increase`
- Print built-in items: `sudo docker exec zabbix-agent zabbix_agentd -p | head`

## Proxy Configuration
- Environment applied: `sudo docker exec zabbix-proxy env | grep ZBX_`
- PSK secret file: `sudo docker exec zabbix-proxy cat /var/lib/zabbix/enc/secret.psk`
- Server target:
  - `sudo docker exec zabbix-proxy env | grep ZBX_SERVER_HOST`
  - `grep ZBX_SERVER_HOST /zabbix/env_vars/.env_prx`
  - Note: the image reads `ZBX_*` environment variables; the base `zabbix_proxy.conf` includes modular files and may not contain the server host directly.

## Common Errors & Fixes
- YAML error ("mapping values are not allowed"):
  - Inspect `/zabbix/docker-compose.yml` and fix indentation/empty keys.
  - Validate: `sudo docker compose config`.
- Permission denied to `/var/run/docker.sock`:
  - Add user to docker group: `sudo usermod -aG docker $USER`
  - Refresh session: `newgrp docker` or new terminal; temporarily use `sudo docker ...`.
- Missing Python Docker SDK for Ansible modules:
  - `sudo apt install -y python3-pip && sudo pip3 install docker`
- Compose v2 missing:
  - Install plugin: `sudo apt install -y docker-compose-plugin`
  - Verify: `docker compose version`

## Zabbix API Readiness
- Wait for server/proxy ports before API calls:
  - Server: `timeout 1 bash -c '</dev/tcp/127.0.0.1/10051' && echo Server OK || echo WAIT'`
  - Proxy: `timeout 1 bash -c '</dev/tcp/127.0.0.1/10051' && echo Proxy OK || echo WAIT'`
- Check credentials/vault values (`zabbix_url`, `zabbix_api_user`, `zabbix_api_pass`).

## Regenerate PSK
- Path on host: `/zabbix/zbx_env/var/enc/secret.psk`
- Permissions: `sudo chmod 0640 /zabbix/zbx_env/var/enc/secret.psk`
- Re-run playbook to auto-generate if missing.

## Compose File Locations
- Compose project directory: `/zabbix`
- Env files rendered: `/zabbix/env_vars/.env_*`
- Local volumes base: `/zabbix/zbx_env/...`

## Collect Diagnostics
- Compose details: `sudo docker compose config > /tmp/compose.out`
- Container inspect:
  - `sudo docker inspect zabbix-agent > /tmp/agent.inspect.json`
  - `sudo docker inspect zabbix-proxy > /tmp/proxy.inspect.json`
- Share offending lines (first ~60) from `/zabbix/docker-compose.yml` when reporting YAML errors.

