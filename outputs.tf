output "host" {
  description = "Hostname of the container."
  value       = docker_container.app.hostname
}
