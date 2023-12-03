########### metrics-server ##########
resource "helm_release" "metrics-server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = false

  set {
    name = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

