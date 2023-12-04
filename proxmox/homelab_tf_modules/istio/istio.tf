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
  }
}

resource "helm_release" "istio-ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace_v1.istio_ingress.id

  set {
    name  = "service.loadBalancerIP"
    value = var.istio_lb_ip
  }

  set {
    name  = "service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [kubernetes_namespace_v1.istio_ingress]
}

# istio gateway
resource "kubectl_manifest" "istio-gateway" {
  yaml_body  = <<-YAML
  apiVersion: networking.istio.io/v1beta1
  kind: Gateway
  metadata:
    name: istio-gateway
    namespace: istio-system
  spec:
    selector:
      istio: ingress
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"
    - port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: istio-tls-secret
      hosts:
      - "*"
    YAML
  depends_on = [kubectl_manifest.tls]
}

