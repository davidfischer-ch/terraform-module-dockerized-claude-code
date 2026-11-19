mock_provider "docker" {}
mock_provider "local" {}

variables {
  identifier       = "my-claude"
  image_id         = "sha256:0123456789abcdef"
  network_id       = "my-network"
  config_directory = "/data/my-claude/config"
}

run "named_volume_is_mounted_by_its_name" {
  command = plan

  variables {
    extra_volumes = {
      cache = { container_path = "/home/app/.cache", volume_name = "my-claude-cache" }
    }
  }

  assert {
    condition = anytrue([
      for volume in docker_container.app.volumes :
      volume.volume_name == "my-claude-cache" && volume.container_path == "/home/app/.cache"
    ])
    error_message = join(" ", [
      "A named volume must not be mounted as an anonymous one,",
      "lost at each replacement.",
    ])
  }
}

run "volumes_of_another_container_are_mounted" {
  command = plan

  variables {
    extra_volumes = {
      shared = { from_container = "my-other-container" }
    }
  }

  assert {
    condition = anytrue([
      for volume in docker_container.app.volumes : volume.from_container == "my-other-container"
    ])
    error_message = "The volumes of `from_container` must reach the container."
  }
}
