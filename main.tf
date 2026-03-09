resource "docker_container" "app" {

  image = var.image_id
  name  = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = var.restart

  privileged = var.privileged

  dynamic "capabilities" {
    for_each = length(var.cap_add) + length(var.cap_drop) > 0 ? [1] : []
    content {
      add  = var.cap_add
      drop = var.cap_drop
    }
  }

  user = var.data_owner

  entrypoint = ["fixuid", "-q", "sleep", "infinity"]
  command    = []

  env = formatlist("%s=%s", keys(local.env), values(local.env))

  hostname = var.identifier

  dynamic "host" {
    for_each = local.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  networks_advanced {
    name = var.network_id
  }

  network_mode = "bridge"

  volumes {
    container_path = local.container_config_directory
    host_path      = local.host_config_directory
    read_only      = false
  }

  dynamic "volumes" {
    for_each = var.extra_volumes
    content {
      container_path = volumes.value.container_path
      host_path      = volumes.value.host_path
      read_only      = volumes.value.read_only
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p "${local.host_config_directory}"
      chown "${var.data_owner}" "${local.host_config_directory}"
    EOT
  }
}
