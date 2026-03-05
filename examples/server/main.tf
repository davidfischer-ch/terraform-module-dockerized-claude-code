resource "docker_image" "claude_code" {
  name         = "your-registry.example.com/claude-code:latest"
  keep_locally = true
}

resource "docker_network" "claude_code" {
  name   = "claude-code"
  driver = "bridge"
}

module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=main"

  identifier = "claude-code"
  enabled    = true
  image_id   = docker_image.claude_code.image_id
  restart    = "always"

  api_key = var.anthropic_api_key
  model   = "claude-sonnet-4-6"

  # Security

  privileged = true
  cap_drop   = ["CAP_NET_RAW", "CAP_SYS_PTRACE", "CAP_MKNOD"]

  # Networking

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
