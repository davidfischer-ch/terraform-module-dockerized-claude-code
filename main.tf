resource "local_file" "ca_bundle" {
  count    = var.ca_bundle != "" ? 1 : 0
  filename = "${local.host_config_directory}/ca-bundle.pem"
  content  = var.ca_bundle
}

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
      add  = [for cap in var.cap_add : "CAP_${cap}"]
      drop = [for cap in var.cap_drop : "CAP_${cap}"]
    }
  }

  user = "${var.app_uid}:${var.app_gid}"

  entrypoint = ["fixuid", "-q", "sleep", "infinity"]
  command    = []

  env = formatlist("%s=%s", keys(local.env), values(local.env))

  group_add = var.extra_groups

  dynamic "host" {
    for_each = local.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  hostname = var.identifier

  network_mode = "bridge"

  networks_advanced {
    name = var.network_id
  }

  dynamic "devices" {
    for_each = var.extra_devices
    content {
      container_path = devices.value.container_path
      host_path      = devices.value.host_path
      permissions    = devices.value.permissions
    }
  }

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

  depends_on = [local_file.ca_bundle]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p "${local.host_config_directory}"
      chown "${var.app_uid}:${var.app_gid}" "${local.host_config_directory}"
    EOT
  }
}
