
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd.id
#  set {
#    name  = "server.service.type"
#    value = "LoadBalancer"
#  }
#  set {
#    name  = "server.service.loadBalancerIP"
#    value = "172.17.9.14"
#  }
  set {
    name  = "controller.metrics.enabled"
    value = true
  }
  set {
    name  = "repoServer.metrics.enabled"
    value = true
  }
  set {
    name  = "server.metrics.enabled"
    value = true
  }
}
