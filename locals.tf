locals {
  container_config_directory  = "/home/app/.claude"
  host_config_directory       = var.config_directory != "" ? var.config_directory : "${var.data_directory}/config"

  env = merge(var.env, {
    ANTHROPIC_API_KEY = var.api_key
    ANTHROPIC_MODEL   = var.model
  })
}
