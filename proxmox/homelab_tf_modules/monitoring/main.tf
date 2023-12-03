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
