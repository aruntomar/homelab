resource "proxmox_vm_qemu" "vm" {
  # name of the new vm
  name = "vm1"
  # description of the vm
  desc = "vm created by terraform"
  # target node is the name of the proxmox server on which the vm should be deployed. 
  target_node = "pve"

  # name of the vm template to clone
  clone = "temp-debian-12"

  # disk configuration for the vm
  disk {
    type    = "virtio"
    storage = "local-lvm"
    size    = "10G"
  }

  # network configuration for the vm
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  ipconfig0  = "ip=172.17.9.5/24,gw=172.17.9.1"
  nameserver = "1.1.1.1"

  # vm resource configuration
  cores   = 2
  sockets = 1
  memory  = 1024

  ssh_user = "debian"
  os_type  = "cloud-init"

  sshkeys = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmsnhVKDq+uiEE+74Tu/O6xNzOD8sUau23oaUaZ3o/4 arun@arch-t14
EOF

  # connection params for the remote-exec provisioner to use. 
  connection {
    type = "ssh"
    user = self.ssh_user
    host = "172.17.9.5"
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}

