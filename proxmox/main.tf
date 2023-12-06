module "k8s_kubeadm" {
  source = "../homelab_tf_modules/k8s_kubeadm"
}

## read terraform remote state and get k8s cluster credentials. 
#data "terraform_remote_state" "k8s_cluster" {
#  backend = "local"
#  config = {
#    path = "${path.module}/../k8s_kubeadm/terraform.tfstate"
#  }
#}

# storage
module "storage" {
  source     = "../homelab_tf_modules/longhorn"
  depends_on = [module.k8s_kubeadm]
}

module "lb" {
  source     = "../homelab_tf_modules/metallb"
  depends_on = [module.k8s_kubeadm]
}

module "certmgr" {
  source     = "../homelab_tf_modules/cert-manager"
  depends_on = [module.k8s_kubeadm]
}

module "istio" {
  source     = "../homelab_tf_modules/istio"
  depends_on = [module.lb, module.certmgr]
}

module "monitoring" {
  source     = "../homelab_tf_modules/monitoring"
  depends_on = [module.istio, module.storage]
}

module "system_apps" {
  source     = "../homelab_tf_modules/k8s_system_apps"
  depends_on = [module.k8s_kubeadm, module.lb, module.istio]
}
