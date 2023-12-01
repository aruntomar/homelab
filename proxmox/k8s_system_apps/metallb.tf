resource "kubernetes_namespace_v1" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace_v1.metallb.id

  depends_on = [kubernetes_namespace_v1.metallb]
}

resource "kubectl_manifest" "metallb_pool" {
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: metallb-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.17.9.10-172.17.9.49
YAML
  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb_ad" {
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-l2-ad
  namespace: metallb-system
spec:
  ipAddressPools:
    - metallb-pool
YAML
  depends_on = [helm_release.metallb]
}

