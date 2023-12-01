resource "kubernetes_namespace_v1" "istio" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace_v1.istio.id
  depends_on = [kubernetes_namespace_v1.istio]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace_v1.istio.id
  depends_on = [kubernetes_namespace_v1.istio]
}

resource "kubernetes_namespace_v1" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace_v1.istio_ingress.id

  set {
    name  = "service.loadBalancerIP"
    value = "172.17.9.10"
  }

  depends_on = [kubernetes_namespace_v1.istio_ingress]
}
