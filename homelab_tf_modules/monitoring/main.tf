resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace_v1.monitoring.id
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace_v1.monitoring.id
  }
  data = {
    "eks_cluster.json" = file("${path.module}/k8s_dashboard.json")
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace_v1.monitoring.id
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  set {
    name  = "dashboardsConfigMaps.default"
    value = kubernetes_config_map.grafana_dashboards.metadata[0].name
  }

  values = [
    jsonencode(local.grafana_values)
  ]

  depends_on = [helm_release.prometheus, kubernetes_config_map.grafana_dashboards]
}

resource "kubectl_manifest" "grafana-vs" {
  yaml_body = <<-YAML
  apiVersion: networking.istio.io/v1beta1
  kind: VirtualService
  metadata:
    name: grafana-vs
    namespace: monitoring
  spec:
    hosts:
      - "*"
    gateways:
      - istio-system/istio-gateway
    http:
      - match:
          - uri:
              prefix: /grafana
          - uri:
              exact: /login
        route:
          - destination:
              host: grafana.monitoring.svc.cluster.local
              port:
                number: 80
  YAML
}
