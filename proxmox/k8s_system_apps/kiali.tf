resource "helm_release" "kiali" {
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  name       = "kiali-server"
  namespace  = kubernetes_namespace_v1.istio.id
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }
}
