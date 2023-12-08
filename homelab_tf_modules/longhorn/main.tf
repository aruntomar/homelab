resource "kubernetes_namespace_v1" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.5.2"
  namespace  = kubernetes_namespace_v1.longhorn.id

  provisioner "local-exec" {
    command = <<-EOF
      kubectl -n longhorn-system patch -p '{"value": "true"}' --type=merge lhs deleting-confirmation-flag
    EOF
    when    = destroy
  }

  depends_on = [
    kubernetes_namespace_v1.longhorn
  ]
}
