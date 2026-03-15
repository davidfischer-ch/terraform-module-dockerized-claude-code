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
  default     = true
}

variable "restart" {
  type        = string
  description = "Container restart policy. Use 'no' to prevent automatic restart on system boot."
  default     = "always"

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
  description = "UID of the user running the container and owning the data directories."
  default     = 1000
}

variable "app_gid" {
  type        = number
  description = "GID of the user running the container and owning the data directories."
  default     = 1000
}

variable "privileged" {
  type        = bool
  description = "Run the container in privileged mode."
  default     = false
}

variable "cap_add" {
  type        = set(string)
  description = "Linux capabilities to add to the container."
  default     = []
  validation {
    condition     = length(setsubtract(var.cap_add, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_add` must be a valid Linux capability name."
  }
}

variable "cap_drop" {
  type        = set(string)
  description = "Linux capabilities to drop from the container."
  default     = []
  validation {
    condition     = length(setsubtract(var.cap_drop, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_drop` must be a valid Linux capability name."
  }
}

# Devices ------------------------------------------------------------------------------------------

variable "extra_devices" {
  type = map(object({
    container_path = string
    host_path      = string
    permissions    = string
  }))
  description = "Extra devices to expose to the container (e.g. USB, serial)."
  default     = {}
}

variable "extra_groups" {
  type        = set(string)
  description = "Additional groups for the container user."
  default     = []
}

# Networking ---------------------------------------------------------------------------------------

variable "ca_bundle" {
  type        = string
  description = <<-EOT
    PEM content of the CA bundle to trust in the container (use file() to load).
    Sets NODE_EXTRA_CA_CERTS, CURL_CA_BUNDLE and REQUESTS_CA_BUNDLE.
  EOT
  default     = ""
}

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
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
    container_path = optional(string)
    from_container = optional(string)
    host_path      = optional(string)
    read_only      = optional(bool)
    volume_name    = optional(string)
  }))
  description = "Extra volumes to mount in the container."
  default     = {}
}

# Configuration ------------------------------------------------------------------------------------

variable "api_key" {
  type        = string
  description = "Anthropic API key for Claude. Leave empty to use OAuth login instead."
  default     = ""
  sensitive   = true
}

variable "model" {
  type        = string
  description = "Claude model to use."
  default     = "claude-sonnet-4-6"

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
  description = "Enable Claude Code auto-updates (disabled by default for CI reproducibility)."
  default     = false
}

variable "env" {
  type        = map(string)
  description = "Extra environment variables to pass to the container."
  default     = {}
}
