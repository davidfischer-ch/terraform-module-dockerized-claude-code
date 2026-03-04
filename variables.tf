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

variable "image_id" {
  type        = string
  description = "Claude Code image's ID."
}

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

variable "data_owner" {
  type        = string
  default     = "1000:1000"
  description = "Owner (uid:gid) for the data directories."
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

# Security -----------------------------------------------------------------------------------------

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

# Networking ---------------------------------------------------------------------------------------

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
  default     = ""
  description = "Host path to mount as ~/.claude. Defaults to {data_directory}/config when empty."
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
