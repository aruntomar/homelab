variable "vm_count" {
  type    = number
  default = 1
}

variable "pve_host" {
  type    = string
  default = "172.17.9.2"
}

resource "null_resource" "cloud_init_config_files" {
  count = var.vm_count
  connection {
    type = "ssh"
    host = var.pve_host
  }

  provisioner "file" {
    source      = "cloud-config.yaml"
    destination = "/var/lib/vz/snippets/user_data_vm-${count.index}.yml"
  }
}

resource "proxmox_vm_qemu" "vm" {
  count       = var.vm_count
  agent       = 1
  name        = "vm1"
  desc        = "vm created by terraform"
  target_node = "pve"

  clone = "debian-bookworm-template"

  # The destination resource pool for the new VM
  # pool = "local-lvm"

  disk {
    type    = "virtio"
    storage = "local-lvm"
    size    = "10G"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  cores   = 2
  sockets = 1
  memory  = 1024

  cicustom  = "user=local:snippets/user_data_vm-${count.index}.yml"
  ssh_user  = "test"
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  /* Create the Cloud-Init drive on the "local-lvm" storage */
  # cloudinit_cdrom_storage = "local-lvm"
  sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmsnhVKDq+uiEE+74Tu/O6xNzOD8sUau23oaUaZ3o/4 arun@arch-t14
    EOF

  connection {
    type = "ssh"
    user = self.ssh_user
    host = self.ssh_host
    port = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}

