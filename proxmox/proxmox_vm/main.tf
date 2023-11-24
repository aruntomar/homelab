/* Uses Cloud-Init options from Proxmox 5.2 */
resource "proxmox_vm_qemu" "vm" {
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

  ssh_user  = "debian"
  os_type   = "cloud-init"
  ipconfig0 = "ip=172.17.9.5/24,gw=172.17.9.1"
  nameserver = "1.1.1.1"

  sshkeys = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmsnhVKDq+uiEE+74Tu/O6xNzOD8sUau23oaUaZ3o/4 arun@arch-t14
EOF

  connection {
    type        = "ssh"
    user        = self.ssh_user
    host        = "172.17.9.5"
    port        = 22
  }

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}

