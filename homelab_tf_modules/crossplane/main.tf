########## crossplane-system namespace ##########
resource "kubernetes_namespace_v1" "crossplane-system" {
  metadata {
    name = "crossplane-system"
  }
}

resource "helm_release" "cert_manager" {
  name       = "crossplane-system"
  repository = "https://charts.crossplane.io/stable"
  chart      = "crossplane"
  namespace  = kubernetes_namespace_v1.crossplane-system.id
}

