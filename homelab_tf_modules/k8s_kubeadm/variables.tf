locals {
  # common
  agent          = var.agent? 1 : 0
  ci_custom      = var.ci_custom
  ci_user        = var.ci_user
  cpu_cores      = 4
  cpu_socket     = 1
  clone_source   = var.clone_source
  cpu_type       = var.cpu_type
  disk_type      = var.disk_type
  k8s_node_count = var.k8s_node_count
  nameserver     = var.nameserver
  network_model  = var.network_model
  network_bridge = var.network_bridge
  os_type        = "cloud-init"
  onboot         = true
  qemu_os        = "l26"
  scsi_ctrl      = "virtio-scsi-pci"
  storage        = var.storage
  ssh_user       = local.ci_user
  ssh_pvt_key    = file(pathexpand(var.ssh_pvt_key))
  ssh_pub_key    = file(pathexpand(var.ssh_pub_key))
  target_node    = var.target_node
}

variable "agent" {
  default = true
  description = "should qemu agent be enabled"
  type = bool
}

variable "ci_custom" {
  default = "user=local:snippets/user_data_vm-0.yml"
  description = "ci custom data"
  type = string
}

variable "ci_user" {
  default = "test"
  description = "default ssh user for the linux vm"
  type = string
}

variable "clone_source" {
  default = "bookworm-k8s-template"
  description = "vm template to clone"
  type = string
}

variable "cpu_type" {
  default = "host"
  description = "cpu type"
  type = string
}

variable "disk_type" {
  default = "scsi"
  description = "type of virtual hd for vm"
  type = string
}


variable "kubeconfig_filepath" {
  default     = "~/.kube/configs/pve"
  description = "location of the kubeconfig file"
  type        = string
}

variable "k8s_node_count" {
  default = 3
  description = "k8s node count for k8s cluster"
  type = number
}

variable "nameserver" {
  default = "1.1.1.1"
  description = "nameserver for the vms"
  type = string
}

variable "network_bridge" {
  default = "vmbr0" 
  description = "name of the network bridge"
  type = string
}

variable "network_model" {
  default = "virtio"
  description = "network model name"  
  type = string
}

variable "target_node" {
  default = "pve"
  description = "name of the target node"
  type = string
}

variable "ssh_pvt_key" {
  default = "~/.ssh/id_ed25519"
  description = "pvt ssh key path"
  type = string
}

variable "ssh_pub_key" {
  default = "~/.ssh/id_ed25519.pub"
  description = "public ssh key path"
  type = string
}

variable "storage" {
  default = "local-lvm"
  description = "storage on proxmox server"
  type = string
}
