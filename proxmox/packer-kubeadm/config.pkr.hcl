packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-clone" "testvm" {
  #  cloud_init               = true
  clone_vm_id              = 9000
  cores                    = 2
  cpu_type                 = "host"
  insecure_skip_tls_verify = true
  memory                   = 2048
  node                     = "pve"
  os                       = "l26"
  proxmox_url              = "https://172.17.9.2:8006/api2/json"
  scsi_controller          = "virtio-scsi-single"
  ssh_username             = "test"
  ssh_private_key_file     = "/home/arun/.ssh/id_ed25519"
  vm_id                    = 8000
  vm_name                  = "bookworm-k8s-template"
}


build {
  sources = ["source.proxmox-clone.testvm"]
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      "sudo apt-get install -y containerd apt-transport-https ca-certificates curl gpg jq wget curl open-iscsi nfs-common mawk dnsutils vim qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent",
      "containerd config default | sudo tee /etc/containerd/config.toml",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml",
      "echo net.ipv4.ip_forward=1 | sudo tee -a /etc/sysctl.conf",
      "echo br_netfilter |sudo tee -a  /etc/modules-load.d/k8s.conf",
      "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo cloud-init clean",
      "sudo truncate -s 0 /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }
  post-processor "shell-local" {
    inline = [
      "ssh root@172.17.9.2 qm set 8000 --ide2 local-lvm:cloudinit"
    ] 
  }
}
