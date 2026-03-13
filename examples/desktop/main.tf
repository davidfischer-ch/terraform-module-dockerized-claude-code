resource "docker_image" "claude_code" {
  name         = "your-registry.example.com/claude-code:latest"
  keep_locally = true
}

resource "docker_network" "claude_code" {
  name   = "claude-code"
  driver = "bridge"
}

module "claude_code" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code.git?ref=1.2.0"

  identifier = "claude-code"
  image_id   = docker_image.claude_code.image_id
  restart    = "no"

  # Process

  privileged = true
  cap_drop   = ["NET_RAW", "SYS_PTRACE", "MKNOD"]

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

  # Configuration — use OAuth login instead of an API key

  model = "claude-sonnet-4-6"
}
