# deploy k8s controller
resource "proxmox_vm_qemu" "k8s-ctrlr" {
  name        = "k8s-ctrlr"
  desc        = "kubernetes controller"
  target_node = local.target_node
  clone       = local.clone_source
  agent       = local.agent
  cores       = local.ctrl_config.cpu_cores
  sockets     = local.ctrl_config.cpu_socket
  cpu         = local.cpu_type
  memory      = local.ctrl_config.memory
  scsihw      = local.scsi_ctrl
  onboot      = local.onboot
  vmid        = local.ctrl_config.vmid
  qemu_os     = local.qemu_os
  disk {
    type    = local.disk_type
    storage = local.storage
    size    = local.ctrl_config.disk_size
  }
  network {
    model  = local.network_model
    bridge = local.network_bridge
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
      "sudo kubeadm init --control-plane-endpoint=${self.default_ipv4_address} --node-name k8s-ctrlr --pod-network-cidr=${local.pod_network_cidr}",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml",
      "kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e 's/strictARP: false/strictARP: true/' | kubectl apply -f - -n kube-system"
    ]
  }
}

# data source to generate the command to join the k8s cluster. 
data "external" "join_cmd" {
  program    = ["sh", "-c", "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address} 'kubeadm token create --print-join-command' |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-ctrlr]
}

# deploy k8s nodes.
resource "proxmox_vm_qemu" "k8s-node" {
  name        = "k8s-node-${count.index + 1}"
  count       = local.k8s_node_count
  desc        = "Kubernetes Node"
  target_node = local.target_node
  clone       = local.clone_source
  agent       = local.agent
  cores       = local.node_config.cpu_cores
  sockets     = local.node_config.cpu_socket
  cpu         = local.cpu_type
  memory      = local.node_config.memory
  scsihw      = local.scsi_ctrl
  onboot      = local.onboot
  vmid        = local.ctrl_config.vmid + count.index + 1
  qemu_os     = local.qemu_os
  disk {
    type    = local.disk_type
    storage = local.storage
    size    = local.node_config.disk_size
  }
  network {
    model  = local.network_model
    bridge = local.network_bridge
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

# display kubeconfig in terraform output
data "external" "kubeconfig" {
  program    = ["sh", "-c", "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address} cat /home/${local.ssh_user}/.kube/config |jq -sR '{output: .}'"]
  depends_on = [proxmox_vm_qemu.k8s-node]
}

# join the k8s nodes to the k8s cluster.
resource "terraform_data" "join_cluster" {
  count = local.k8s_node_count
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-node[count.index].default_ipv4_address} sudo ${chomp(data.external.join_cmd.result.output)}"
  }
  triggers_replace = [proxmox_vm_qemu.k8s-ctrlr.id]
}

locals {
  kubeconfig_filepath = var.kubeconfig_filepath
}

# copy kubeconfig to local machine
resource "null_resource" "copy_kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${local.ssh_user}@${proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address}:/home/${local.ssh_user}/.kube/config  ${local.kubeconfig_filepath}"
  }
}

resource "null_resource" "delete_kubeconfig" {
  triggers = {
    filepath = local.kubeconfig_filepath
  }

  provisioner "local-exec" {
    command = "rm -rf ${self.triggers.filepath}"
    when    = destroy
  }
}

