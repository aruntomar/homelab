terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://172.17.9.2:8006/api2/json"
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

provider "helm" {
  kubernetes {
    config_path = "~/.kube/configs/pve"
  }
}
provider "kubectl" {
  config_path = "~/.kube/configs/pve"
}
provider "kubernetes" {
  config_path = "~/.kube/configs/pve"
}

