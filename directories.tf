resource "terraform_data" "data_directories" {
  triggers_replace = [local.host_config_directory, "${var.app_uid}:${var.app_gid}"]

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p '${replace(local.host_config_directory, "'", "'\\''")}'
      chown -R ${var.app_uid}:${var.app_gid} '${replace(local.host_config_directory, "'", "'\\''")}'
    EOT
  }
}
