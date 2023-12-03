locals {
  #Prometheus to Grafana 
  grafana_values = {
    datasources = {
      "datasources.yaml" = {
        apiVersion = 1
        datasources = [{
          name      = "Prometheus"
          type      = "prometheus"
          url       = "http://prometheus-server.monitoring.svc.cluster.local"
          access    = "proxy"
          isDefault = true
          jsonData = {
            httpMethod     = "POST"
            prometheusType = "Prometheus"
          }
        }]
      }
    }

    dashboardsConfigMaps = {
      default = {
        eks-cluster-monitoring = "grafana-dashbords"
      }
    }

    grafanaIni = {
      "auth.anonymous" = {
        enabled = true
      }
    }

    dashboardProviders = {
      "dashboardproviders.yaml" = {
        apiVersion = 1
        providers = [{
          name            = "default"
          orgId           = 1
          folder          = ""
          type            = "file"
          disableDeletion = false
          options = {
            path = "/var/lib/grafana/dashboards/default"
          }
        }]
      }
    }
  }
}
