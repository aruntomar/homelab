locals {
  # common
  agent          = 1
  ci_custom      = "user=local:snippets/user_data_vm-0.yml"
  ci_user        = "test"
  cpu_cores      = 4
  cpu_socket     = 1
  clone_source   = "bookworm-k8s-template"
  cpu_type       = "host"
  disk_type      = "scsi"
  k8s_node_count = 3
  nameserver     = "1.1.1.1"
  network_model  = "virtio"
  network_bridge = "vmbr0"
  os_type        = "cloud-init"
  onboot         = true
  qemu_os        = "l26"
  scsi_ctrl      = "virtio-scsi-pci"
  storage        = "local-lvm"
  ssh_user       = local.ci_user
  ssh_pvt_key    = file(pathexpand("~/.ssh/id_ed25519"))
  ssh_pub_key    = file(pathexpand("~/.ssh/id_ed25519.pub"))
  target_node    = "pve"
}

variable "kubeconfig_filepath" {
 default = "~/.kube/configs/pve"
 description = "location of the kubeconfig file"
 type = string
}
