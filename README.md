# Claude Code Terraform Module (Dockerized)

Manage Claude Code (Anthropic's AI coding assistant).

* Runs in bridge networking mode
* Persists config directory
* Configurable privileged mode with capability control
* Supports extra volumes for additional read-only or read-write mounts

## Usage

See [examples/server](examples/server) and [examples/desktop](examples/desktop) for complete working configurations.

### [Server](examples/server) (API key, always restart)

```hcl
module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier = "claude-code"
  enabled    = true
  image_id   = docker_image.claude_code.image_id
  restart    = "always"

  # Configuration

  api_key = var.anthropic_api_key
  model   = "claude-sonnet-4-6"

  # Security

  privileged = true
  cap_drop   = ["CAP_NET_RAW", "CAP_SYS_PTRACE", "CAP_MKNOD"]

  # Networking

  network_id = docker_network.claude_code.id

  # Storage

  config_directory = "/data/claude-code/config"
}
```

### [Desktop](examples/desktop) (OAuth login, no auto-start on boot)

```hcl
module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier = "claude-code"
  enabled    = true
  image_id   = docker_image.claude_code.image_id
  restart    = "no"

  # Use OAuth login instead of an API key
  model = "claude-sonnet-4-6"

  # Security

  privileged = true
  cap_drop   = ["CAP_NET_RAW", "CAP_SYS_PTRACE", "CAP_MKNOD"]

  # Networking

  network_id = docker_network.claude_code.id

  # Storage — reuse the existing ~/.claude from the desktop user

  config_directory = "/home/david/.claude"

  extra_volumes = {
    my_project = {
      container_path = "/home/david/projects/my-project"
      host_path      = "/home/david/projects/my-project"
      read_only      = false
    }
  }
}
```

### With extra volumes and custom CA

```hcl
module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier = "claude-code"
  enabled    = true
  image_id   = docker_image.claude_code.image_id
  restart    = "always"
  app_uid    = 1000
  app_gid    = 1000

  # Configuration

  api_key = var.anthropic_api_key
  model   = "claude-sonnet-4-6"

  env = {
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
  }

  # Security

  privileged = true
  cap_drop   = ["CAP_NET_RAW", "CAP_SYS_PTRACE", "CAP_MKNOD"]

  # Networking

  ca_bundle  = sensitive(file("/etc/ssl/certs/my-corp-ca.pem"))
  hosts      = { "myserver" = "10.0.0.1" }
  network_id = docker_network.claude_code.id

  # Storage

  config_directory = "/data/claude-code/config"

  extra_volumes = {
    my_project = {
      container_path = "/home/app/my-project"
      host_path      = "/data/projects/my-project"
      read_only      = false
    }
    documentation = {
      container_path = "/home/app/docs"
      host_path      = "/data/shared/documentation"
      read_only      = true
    }
  }
}
```

## Authentication

Claude Code supports two separate authentication methods with **different billing systems**:

* **API key** (`api_key` variable) — Uses prepaid credits purchased at [console.anthropic.com](https://console.anthropic.com/settings/billing). The module passes this as the `ANTHROPIC_API_KEY` environment variable.
* **OAuth login** (`claude /login`) — Uses your Claude Pro/Max subscription from [claude.ai](https://claude.ai). Run `claude /login` interactively inside the container.

These are not interchangeable: a Claude Pro/Max subscription does not provide API credits, and API credits do not grant a subscription. Choose one method, not both.

If you prefer OAuth, omit `api_key` (or leave it empty) and authenticate via `claude /login` inside the container.

## File ownership

A Docker image defines an internal user (e.g. `app` with UID 1001) that may not match the actual UID/GID of the host user who owns the mounted volumes. When these differ, the container either cannot write to the volumes or creates files with the wrong ownership on the host.

This module sets the container's `user` to `app_uid:app_gid` and wraps the entrypoint with [fixuid](https://github.com/boxboat/fixuid). At startup, fixuid adjusts the in-container user's UID/GID to match `app_uid`/`app_gid`, so files created inside the container have the correct ownership on the host. Your Docker image must include fixuid for this to work.

## Data layout

| Container Path | Host Path | Mode |
|---|---|---|
| `/home/app/.claude` | `{config_directory}` | read-write |
| `/home/app/.claude.json` | Symlink → `.claude/.claude.json` | (via config volume) |

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | — | Start or stop the container. |
| `restart` | `string` | `"always"` | Restart policy: `no`, `always`, `on-failure`, `unless-stopped`. |
| `image_id` | `string` | — | Claude Code Docker image's ID. |
| `app_uid` | `number` | `1000` | UID of the user running the container and owning the data directories. |
| `app_gid` | `number` | `1000` | GID of the user running the container and owning the data directories. |
| `privileged` | `bool` | `false` | Run the container in privileged mode. |
| `cap_add` | `set(string)` | `[]` | Linux capabilities to add to the container. |
| `cap_drop` | `set(string)` | `[]` | Linux capabilities to drop from the container. |
| `api_key` | `string` | `""` | Anthropic API key (sensitive). Leave empty to use OAuth login. |
| `model` | `string` | `"claude-sonnet-4-6"` | Claude model to use. |
| `auto_update` | `bool` | `false` | Enable Claude Code auto-updates. |
| `env` | `map(string)` | `{}` | Extra environment variables. |
| `ca_bundle` | `string` | `""` | PEM content of a CA bundle to trust (use `file(...)` to load). Sets `NODE_EXTRA_CA_CERTS`, `CURL_CA_BUNDLE`, and `REQUESTS_CA_BUNDLE`. |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the container. |
| `network_id` | `string` | — | Docker network to attach to. |
| `extra_volumes` | `map(object)` | `{}` | Extra volumes to mount. |

## Outputs

| Name | Description |
|------|-------------|
| `host` | Container hostname. |

## Requirements

* Terraform >= 1.6
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 3.0.2

## References

* https://docs.anthropic.com/en/docs/claude-code
* https://github.com/anthropics/claude-code
* https://www.npmjs.com/package/@anthropic-ai/claude-code
