variable "kubeconfig_filepath" {
  default = "~/.kube/configs/pve"
  description = "location to store the kubeconfig"
  type = string
}
