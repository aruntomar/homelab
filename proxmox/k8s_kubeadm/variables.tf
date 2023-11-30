locals {
  agent          = 1
  bootdisk       = "scsi0"
  ci_custom      = "user=local:snippets/user_data_vm-0.yml"
  ci_user        = "test"
  cpu_cores      = 4
  cpu_socket     = 1
  clone_source   = "bookworm-k8s-template"
  cpu_type       = "host"
  k8s_node_count = 3
  nameserver     = "1.1.1.1"
  os_type        = "cloud-init"
  qemu_os        = "l26"
  scsi_ctrl      = "virtio-scsi-pci"
  storage        = "local-lvm"
  ssh_user       = local.ci_user
  ssh_pvt_key    = file(pathexpand("~/.ssh/id_ed25519"))
  ssh_pub_key    = file(pathexpand("~/.ssh/id_ed25519.pub"))
  target_node    = "pve"
}

