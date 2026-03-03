locals {
  container_config_directory = "/home/user/.claude"
  host_config_directory      = "${var.data_directory}/config"

  env = merge(var.env, {
    ANTHROPIC_API_KEY = var.api_key
    CLAUDE_MODEL      = var.model
  })
}
