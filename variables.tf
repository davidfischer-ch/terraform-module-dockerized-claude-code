variable "identifier" {
  type        = string
  description = "Identifier (must be unique, used to name resources)."
  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "enabled" {
  type        = bool
  description = "Toggle the containers (started or stopped)."
}

variable "restart" {
  type        = string
  default     = "always"
  description = "Container restart policy. Use 'no' to prevent automatic restart on system boot."

  validation {
    condition     = contains(["no", "always", "on-failure", "unless-stopped"], var.restart)
    error_message = "Argument `restart` must be one of: no, always, on-failure, unless-stopped."
  }
}

variable "image_id" {
  type        = string
  description = "Claude Code image's ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  default     = 1000
  description = "UID of the user running the container and owning the data directories."
}

variable "app_gid" {
  type        = number
  default     = 1000
  description = "GID of the user running the container and owning the data directories."
}

variable "privileged" {
  type        = bool
  default     = false
  description = "Run the container in privileged mode."
}

variable "cap_add" {
  type        = set(string)
  default     = []
  description = "Linux capabilities to add to the container."
}

variable "cap_drop" {
  type        = set(string)
  default     = []
  description = "Linux capabilities to drop from the container."
}

# Configuration ------------------------------------------------------------------------------------

variable "api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Anthropic API key for Claude. Leave empty to use OAuth login instead."
}

variable "model" {
  type        = string
  default     = "claude-sonnet-4-6"
  description = "Claude model to use."

  validation {
    condition = contains([
      "claude-opus-4-6",
      "claude-sonnet-4-6",
      "claude-haiku-4-5-20251001"
    ], var.model)
    error_message = "Model should be one of `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`."
  }
}

variable "auto_update" {
  type        = bool
  default     = false
  description = "Enable Claude Code auto-updates (disabled by default for CI reproducibility)."
}

variable "env" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables to pass to the container."
}

# Networking ---------------------------------------------------------------------------------------

variable "ca_bundle" {
  type        = string
  default     = ""
  description = <<-EOT
    PEM content of the CA bundle to trust in the container (use file() to load).
    Sets NODE_EXTRA_CA_CERTS, CURL_CA_BUNDLE and REQUESTS_CA_BUNDLE.
  EOT
}

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Add entries to container hosts file."
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

# Storage ------------------------------------------------------------------------------------------

variable "config_directory" {
  type        = string
  description = "Host path to mount as ~/.claude."
}

variable "extra_volumes" {
  type = map(object({
    container_path = string
    host_path      = string
    read_only      = bool
  }))
  default     = {}
  description = "Extra volumes to mount in the container."
}
