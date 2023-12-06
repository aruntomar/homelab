terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "proxmox" {
  # Configuration options
  pm_tls_insecure = true

  # uncomment to enable debugging
  # pm_debug        = true
  # pm_log_enable   = true
  # pm_log_file     = "terraform-plugin-proxmox.log"
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}

