# read terraform remote state and get k8s cluster credentials. 
data "terraform_remote_state" "k8s_cluster" {
  backend = "local"
  config = {
    path = "${path.module}/../k8s_kubeadm/terraform.tfstate"
  }
}

module "istio" {
  source = "../homelab_tf_modules/istio"
}
