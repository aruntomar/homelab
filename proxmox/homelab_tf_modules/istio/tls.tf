resource "kubectl_manifest" "issuer" {
  yaml_body = <<-YAML
  apiVersion: cert-manager.io/v1
  kind: Issuer
  metadata:
    name: selfsigned-issuer
    namespace: istio-system
  spec:
    selfSigned: {}

  YAML
  depends_on = [
    helm_release.istio-ingress
  ]
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = <<-YAML
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: selfsigned-cluster-issuer
  spec:
    selfSigned: {}

  YAML
  depends_on = [
    kubectl_manifest.issuer
  ]
}


# generate certs for istio gw
resource "kubectl_manifest" "tls" {
  yaml_body = <<-YAML
  apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: istio-tls-secret
    namespace: istio-system
  spec:
    secretName: istio-tls-secret
    dnsNames:
    - "linuxguy.lan"
    issuerRef:
      name: selfsigned-issuer
  YAML
  depends_on = [
    kubectl_manifest.cluster-issuer
  ]
}

