
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
    set {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
    set {
      name  = "server.service.loadBalancerIP"
      value = "172.17.9.14"
    }
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

resource "kubectl_manifest" "argo-vs" {
  yaml_body = <<-YAML
  apiVersion: networking.istio.io/v1beta1
  kind: VirtualService
  metadata:
    name: argocd-vs
    namespace: argocd
  spec:
    hosts:
      - "*"
    gateways:
      - istio-system/istio-gateway
    http:
      - match:
          - uri:
              exact: /argocd
        route:
          - destination:
              host: argocd-server.argocd.svc.cluster.local
              port:
                number: 443
  YAML
}
