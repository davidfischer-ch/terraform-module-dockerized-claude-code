mock_provider "docker" {}
mock_provider "local" {}

variables {
  identifier       = "my-claude"
  image_id         = "sha256:0123456789abcdef"
  network_id       = "my-network"
  config_directory = "/data/my-claude/config"
}

run "config_directory_follows_its_owner" {
  command = plan

  variables {
    app_uid = 1001
    app_gid = 1002
  }

  assert {
    condition     = contains(terraform_data.data_directories.triggers_replace, "1001:1002")
    error_message = "A changed owner must take the config directory over again."
  }
}
