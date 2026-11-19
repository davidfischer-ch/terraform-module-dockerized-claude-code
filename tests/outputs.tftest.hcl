mock_provider "docker" {}
mock_provider "local" {}

variables {
  identifier       = "my-claude"
  image_id         = "sha256:0123456789abcdef"
  network_id       = "my-network"
  config_directory = "/data/my-claude/config"
}

run "outputs_describe_the_container" {
  command = plan

  assert {
    condition     = output.host == "my-claude"
    error_message = "`host` must be the container's hostname, its identifier."
  }
}
