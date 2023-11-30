resource "proxmox_vm_qemu" "k8s-ctrlr" {
  name        = "k8s-ctrlr"
  desc        = "kubernetes controller"
  target_node = local.target_node
  clone       = local.clone_source
  agent       = local.agent
  cores       = local.cpu_cores
  sockets     = local.cpu_socket
  cpu         = local.cpu_type
  memory      = 6144
  scsihw      = local.scsi_ctrl
  # bootdisk    = local.bootdisk
  onboot  = true
  vmid    = 500
  qemu_os = local.qemu_os
  disk {
    type    = "virtio"
    storage = "local-lvm"
    size    = "40G"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  os_type = local.os_type

  #cloud-init config
  ipconfig0  = "ip=172.17.9.3/24,gw=172.17.9.1"
  nameserver = local.nameserver
  ciuser     = local.ci_user
  cicustom   = local.ci_custom
  sshkeys    = local.ssh_pub_key

  ssh_user        = local.ssh_user
  ssh_private_key = local.ssh_pvt_key

  connection {
    type        = "ssh"
    user        = self.ssh_user
    private_key = self.ssh_private_key
    host        = self.ssh_host
    port        = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
      "hostnamectl",
      "sudo kubeadm init --control-plane-endpoint=${self.default_ipv4_address} --node-name k8s-ctrlr --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml",
      "kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e 's/strictARP: false/strictARP: true/' | kubectl apply -f - -n kube-system"
    ]
  }
}

data "external" "join_cmd" {
  program    = ["sh", "-c", "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address} 'kubeadm token create --print-join-command' |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-ctrlr]
}


resource "proxmox_vm_qemu" "k8s-node" {
  name        = "k8s-node-${count.index + 1}"
  count       = local.k8s_node_count
  desc        = "Kubernetes Node"
  target_node = local.target_node
  clone       = local.clone_source
  agent       = local.agent
  cores       = local.cpu_cores
  sockets     = local.cpu_socket
  cpu         = local.cpu_type
  memory      = 8192
  scsihw      = local.scsi_ctrl
  onboot      = true
  # bootdisk    = local.bootdisk
  vmid    = 500 + count.index + 1
  qemu_os = local.qemu_os
  disk {
    type    = "virtio"
    storage = "local-lvm"
    size    = "40G"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  os_type = local.os_type

  #cloud-init config
  ipconfig0  = "ip=172.17.9.${5 + count.index}/24,gw=172.17.9.1"
  nameserver = local.nameserver
  ciuser     = local.ci_user
  cicustom   = local.ci_custom
  sshkeys    = local.ssh_pub_key

  ssh_user        = local.ssh_user
  ssh_private_key = local.ssh_pvt_key

  connection {
    type        = "ssh"
    user        = self.ssh_user
    private_key = self.ssh_private_key
    host        = self.ssh_host
    port        = self.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
    ]
  }

  depends_on = [
    proxmox_vm_qemu.k8s-ctrlr
  ]
}

# join cluster
data "external" "join_cluster" {
  count      = local.k8s_node_count
  program    = ["sh", "-c", "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-node[count.index].default_ipv4_address} sudo ${chomp(data.external.join_cmd.result.output)} |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-node]
}

# display kubeconfig in terraform output
data "external" "kubeconfig" {
  program    = ["sh", "-c", "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address} cat /home/${local.ssh_user}/.kube/config |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-node]
}

# copy kubeconfig to local machine
data "external" "cpy_kubeconf" {
  program    = ["sh", "-c", "scp -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address}:/home/${local.ssh_user}/.kube/config  $HOME/.kube/configs/pve |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-ctrlr]
}
