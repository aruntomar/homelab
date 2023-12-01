output "k8s_ctrlr_ip" {
  value = proxmox_vm_qemu.k8s-ctrlr.default_ipv4_address
}

output "k8s_node_ip" {
  value = proxmox_vm_qemu.k8s-node[*].default_ipv4_address
}

# output "config" {
#   value = local.config
# }

# this output is no longer needed as worker nodes automatically use this information.
# output "k8s-join-cmds" {
#   value = chomp(data.external.join_cmd.result.output)
# }

output "kubeconfig" {
  value = data.external.kubeconfig.result.output
}

output "kubeconfig_filepath" {
  value = local.kubeconfig_filepath
}
