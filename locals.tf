locals {
  container_config_directory = "/home/app/.claude"
  host_config_directory      = var.config_directory

  hosts = merge(
    { "host.docker.internal" = "host-gateway" },
    var.hosts,
  )

  env = merge(
    var.env,
    {
      ANTHROPIC_MODEL     = var.model
      COLORTERM           = "truecolor"
      DISABLE_AUTOUPDATER = var.auto_update ? "" : "1"
    },
    var.api_key != "" ? { ANTHROPIC_API_KEY = var.api_key } : {},
    var.ca_bundle != "" ? {
      CURL_CA_BUNDLE      = "${local.container_config_directory}/ca-bundle.pem"
      NODE_EXTRA_CA_CERTS = "${local.container_config_directory}/ca-bundle.pem"
      REQUESTS_CA_BUNDLE  = "${local.container_config_directory}/ca-bundle.pem"
    } : {},
  )

  linux_capabilities = [
    "ALL",
    "AUDIT_CONTROL",
    "AUDIT_READ",
    "AUDIT_WRITE",
    "BLOCK_SUSPEND",
    "BPF",
    "CHECKPOINT_RESTORE",
    "CHOWN",
    "DAC_OVERRIDE",
    "DAC_READ_SEARCH",
    "FOWNER",
    "FSETID",
    "IPC_LOCK",
    "IPC_OWNER",
    "KILL",
    "LEASE",
    "LINUX_IMMUTABLE",
    "MAC_ADMIN",
    "MAC_OVERRIDE",
    "MKNOD",
    "NET_ADMIN",
    "NET_BIND_SERVICE",
    "NET_BROADCAST",
    "NET_RAW",
    "PERFMON",
    "SETFCAP",
    "SETGID",
    "SETPCAP",
    "SETUID",
    "SYS_ADMIN",
    "SYS_BOOT",
    "SYS_CHROOT",
    "SYS_MODULE",
    "SYS_NICE",
    "SYS_PACCT",
    "SYS_PTRACE",
    "SYS_RAWIO",
    "SYS_RESOURCE",
    "SYS_TIME",
    "SYS_TTY_CONFIG",
    "SYSLOG",
    "WAKE_ALARM"
  ]
}
