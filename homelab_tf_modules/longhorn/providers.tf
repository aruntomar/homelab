terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24"
    }
  }
}

#provider "helm" {
#  kubernetes {
#    config_path = data.terraform_remote_state.k8s_cluster.outputs.kubeconfig_filepath
#  }
#}
#provider "kubectl" {
#  config_path = data.terraform_remote_state.k8s_cluster.outputs.kubeconfig_filepath
#}
#provider "kubernetes" {
#  config_path = data.terraform_remote_state.k8s_cluster.outputs.kubeconfig_filepath
#}
#
