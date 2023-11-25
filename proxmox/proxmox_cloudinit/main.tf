variable "vm_count" {
  type = number 
  default = 1
}

variable "pve_host" {
  type = string
  default = "172.17.9.2"
}

#data "cloudinit_config" "user_data" {
#  gzip          = false
#  base64_encode = false
#
#  part {
#    filename     = "cloud-config.yaml"
#    content_type = "text/cloud-config"
#
#    content = file("${path.module}/cloud-config.yaml")
#  }
#}

## Modify path for templatefile and use the recommended extention of .tftpl for syntax hylighting in code editors.
#resource "local_file" "cloud_init_user_data_file" {
#  count    = var.vm_count
#  content  = templatefile("${var.working_directory}/cloud-inits/cloud-init.cloud_config.tftpl", { ssh_key = var.ssh_public_key, hostname = var.name })
#  filename = "${path.module}/files/user_data_${count.index}.cfg"
#}
#

resource "null_resource" "cloud_init_config_files" {
  count = var.vm_count
  connection {
    type     = "ssh"
    host     = var.pve_host
  }

  provisioner "file" {
    source      = "cloud-config.yaml"
    destination = "/var/lib/vz/snippets/user_data_vm-${count.index}.yml"
  }
}

#/* Configure Cloud-Init User-Data with custom config file */
#resource "proxmox_vm_qemu" "cloudinit-test" {
#  depends_on = [
#    null_resource.cloud_init_config_files,
#  ]
#
#  name        = "tftest1.xyz.com"
#  desc        = "tf description"
#  target_node = "proxmox1-xx"
#
#  clone = "ci-ubuntu-template"
#
#  # The destination resource pool for the new VM
#  pool = "pool0"
#
#  storage = "local"
#  cores   = 3
#  sockets = 1
#  memory  = 2560
#  disk_gb = 4
#  nic     = "virtio"
#  bridge  = "vmbr0"
#
#  ssh_user        = "root"
#  ssh_private_key = <<EOF
#-----BEGIN RSA PRIVATE KEY-----
#private ssh key root
#-----END RSA PRIVATE KEY-----
#EOF
#
#  os_type   = "cloud-init"
#  ipconfig0 = "ip=10.0.2.99/16,gw=10.0.2.2"
#
#  /*
#    sshkeys and other User-Data parameters are specified with a custom config file.
#    In this example each VM has its own config file, previously generated and uploaded to
#    the snippets folder in the local storage in the Proxmox VE server.
#  */
#  cicustom                = "user=local:snippets/user_data_vm-${count.index}.yml"
#  /* Create the Cloud-Init drive on the "local-lvm" storage */
#  cloudinit_cdrom_storage = "local-lvm"
#
#  provisioner "remote-exec" {
#    inline = [
#      "ip a"
#    ]
#  }
#}
#
/* Uses Cloud-Init options from Proxmox 5.2 */
resource "proxmox_vm_qemu" "vm" {
  count = var.vm_count
  agent = 1 
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

  ssh_user  = "test"
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  cicustom                = "user=local:snippets/user_data_vm-${count.index}.yml"
  /* Create the Cloud-Init drive on the "local-lvm" storage */
  # cloudinit_cdrom_storage = "local-lvm"
  sshkeys = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEmsnhVKDq+uiEE+74Tu/O6xNzOD8sUau23oaUaZ3o/4 arun@arch-t14
EOF

  connection {
    type        = "ssh"
    user        = self.ssh_user
    host        = self.ssh_host
    port        = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}

