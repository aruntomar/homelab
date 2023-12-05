resource "helm_release" "kiali" {
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  name       = "kiali-server"
  namespace  = kubernetes_namespace_v1.istio.id
  set {
    name  = "auth.strategy"
    value = "anonymous"
  }
  set {
    name  = "external_services.prometheus.url"
    value = "http://prometheus-server.monitoring.svc.cluster.local:80"
  }
}

resource "kubectl_manifest" "kiali-vs" {
  yaml_body = <<-YAML
  apiVersion: networking.istio.io/v1beta1
  kind: VirtualService
  metadata:
    name: kiali-vs
    namespace: istio-system
  spec:
    hosts:
      - "*"
    gateways:
      - istio-system/istio-gateway
    http:
      - match:
          - uri:
              prefix: /kiali
        route:
          - destination:
              host: kiali.istio-system.svc.cluster.local
              port:
                number: 20001
  YAML
}
