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
        helm = {
          "parameters" = [
            {
              "name"  = "persistence.worker.storageClass"
              "value" = "longhorn"
            },
            {
              "name"  = "jobs.createSite.enabled"
              "value" = "true"
            },
            {
              "name"  = "jobs.createSite.siteName"
              "value" = "erp.linuxguy.lan"
            },
            {
              "name"  = "jobs.createSite.adminPassword"
              "value" = "connected"
            }
          ]
        }
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

resource "kubectl_manifest" "erpnext-vs" {
  yaml_body = <<-YAML
  apiVersion: networking.istio.io/v1beta1
  kind: VirtualService
  metadata:
    name: erpnext-vs
    namespace: erpnext
  spec:
    hosts:
      - "erp.linuxguy.lan"
    gateways:
      - istio-system/istio-gateway
    http:
      - match:
          - uri:
              prefix: /
          - uri:
              prefix: /assets
        route:
          - destination:
              host: frappe-bench-erpnext.erpnext.svc.cluster.local
              port:
                number: 8080
  YAML
}
