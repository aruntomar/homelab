module "k8s_kubeadm" {
  k8s_controller_ip = "172.17.9.3"
  k8s_node_count    = 5
  subnet_mask       = 24
  network_gateway   = "172.17.9.1"
  source            = "../../terraform-proxmox-kubeadm"
}

locals {
  kubeconfig_filepath = var.kubeconfig_filepath
}

resource "local_file" "copy_kubeconfig" {
  content    = module.k8s_kubeadm.kubeconfig
  filename   = pathexpand(local.kubeconfig_filepath)
  depends_on = [module.k8s_kubeadm]
}

# storage
module "storage" {
  source     = "../homelab_tf_modules/longhorn"
  depends_on = [module.k8s_kubeadm, local_file.copy_kubeconfig]
}

# load balancer
module "lb" {
  source     = "../homelab_tf_modules/metallb"
  depends_on = [module.k8s_kubeadm, local_file.copy_kubeconfig]
}

# cert mgr
module "certmgr" {
  source     = "../homelab_tf_modules/cert-manager"
  depends_on = [module.k8s_kubeadm, local_file.copy_kubeconfig]
}

# service mesh
module "istio" {
  source     = "../homelab_tf_modules/istio"
  depends_on = [module.lb, module.certmgr, local_file.copy_kubeconfig]
}

# monitoring
module "monitoring" {
  source     = "../homelab_tf_modules/monitoring"
  depends_on = [module.istio, module.storage, local_file.copy_kubeconfig]
}

# other system apps
module "system_apps" {
  source     = "../homelab_tf_modules/k8s_system_apps"
  depends_on = [module.k8s_kubeadm, module.lb, module.istio, local_file.copy_kubeconfig]
}

# install jenkins
module "jenkins" {
  source     = "../homelab_tf_modules/jenkins"
  depends_on = [module.k8s_kubeadm]
}

module "crossplane" {
  source     = "../homelab_tf_modules/crossplane"
  depends_on = [module.k8s_kubeadm]
}
