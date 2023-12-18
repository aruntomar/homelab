resource "kubernetes_namespace_v1" "erpnext" {
  metadata {
    name = "erpnext"
  }
}

data "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_manifest" "erpnext" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frappe-bench"
      namespace = data.kubernetes_namespace_v1.argocd.id
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://helm.erpnext.com/"
        chart          = "erpnext"
        targetRevision = "7.0.7"
        #        helm = {
        #          "parameters" = [
        #            {
        #              "name"  = "service.http.loadBalancerIP"
        #              "value" = "172.17.9.15"
        #            },
        #            {
        #              "name"  = "service.http.type"
        #              "value" = "LoadBalancer"
        #            },
        #          ]
        #        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace_v1.erpnext.id
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
