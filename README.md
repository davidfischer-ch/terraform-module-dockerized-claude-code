# Claude Code Terraform Module (Dockerized)

Manage Claude Code (Anthropic's AI coding assistant).

* Runs in bridge networking mode
* Persists config directory
* Requires an Anthropic API key (sensitive variable)
* Configurable privileged mode with capability control
* Supports mounting a project directory as workspace
* Supports extra volumes for additional read-only or read-write mounts

## Usage

See [examples/default](examples/default) for a complete working configuration.

### Minimal

```hcl
module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier     = "claude-code"
  enabled        = true
  image_id       = docker_image.claude_code.image_id
  data_directory = "/data/claude-code"

  api_key    = var.anthropic_api_key
  network_id = docker_network.claude_code.id
}
```

### With project workspace and extra volumes

```hcl
module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier     = "claude-code"
  enabled        = true
  image_id       = docker_image.claude_code.image_id
  data_directory = "/data/claude-code"
  data_owner     = "1000:1000"

  # Configuration

  api_key    = var.anthropic_api_key
  model      = "claude-opus-4-6"
  max_turns  = 10

  env = {
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
  }

  # Security

  privileged = true
  cap_drop   = ["CAP_NET_RAW", "CAP_SYS_PTRACE", "CAP_MKNOD"]

  # Networking

  hosts      = { "myserver" = "10.0.0.1" }
  network_id = docker_network.claude_code.id

  # Storage


  extra_volumes = {
    reference_docs = {
      container_path = "/data/docs"
      host_path      = "/data/shared/documentation"
      read_only      = true
    }
    shared_cache = {
      container_path = "/data/cache"
      host_path      = "/data/shared/pip-cache"
      read_only      = false
    }
  }
}
```

## Authentication

The API key is passed directly as the `ANTHROPIC_API_KEY` environment variable, which Claude Code reads natively. No `apiKeyHelper` indirection is needed.

## File ownership

A Docker image defines an internal user (e.g. `app` with UID 1001) that may not match the actual UID/GID of the host user who owns the mounted volumes. When these differ, the container either cannot write to the volumes or creates files with the wrong ownership on the host.

This module sets the container's `user` to the `data_owner` variable and wraps the entrypoint with [fixuid](https://github.com/boxboat/fixuid). At startup, fixuid adjusts the in-container user's UID/GID to match `data_owner`, so files created inside the container have the correct ownership on the host. Your Docker image must include fixuid for this to work.

## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── config/          # Claude settings (~/.claude)
│   └── .claude.json # Symlinked from ~/.claude.json in the image
├── data/            # Working data
└── logs/            # Application logs
```

| Container Path | Host Path | Mode |
|---|---|---|
| `/home/app/.claude` | `{data_directory}/config` | read-write |
| `/home/app/.claude.json` | Symlink → `.claude/.claude.json` | (via config volume) |

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | — | Start or stop the container. |
| `image_id` | `string` | — | Claude Code Docker image's ID. |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `data_owner` | `string` | `"1000:1000"` | UID:GID for data and logs directories. |
| `api_key` | `string` | — | Anthropic API key (sensitive). |
| `model` | `string` | `"claude-sonnet-4-6"` | Claude model to use. |
| `max_turns` | `number` | `0` | Maximum agentic turns (0 for unlimited). |
| `env` | `map(string)` | `{}` | Extra environment variables. |
| `privileged` | `bool` | `false` | Run the container in privileged mode. |
| `cap_add` | `set(string)` | `[]` | Linux capabilities to add to the container. |
| `cap_drop` | `set(string)` | `[]` | Linux capabilities to drop from the container. |
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
