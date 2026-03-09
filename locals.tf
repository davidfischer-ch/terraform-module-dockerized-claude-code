locals {
  container_config_directory = "/home/app/.claude"
  host_config_directory      = var.config_directory

  hosts = merge(
    { "host.docker.internal" = "host-gateway" },
    var.hosts,
  )

  env = merge(
    var.env,
    {
      ANTHROPIC_MODEL     = var.model
      COLORTERM           = "truecolor"
      DISABLE_AUTOUPDATER = var.auto_update ? "" : "1"
    },
    var.api_key != "" ? { ANTHROPIC_API_KEY = var.api_key } : {},
  )
}
