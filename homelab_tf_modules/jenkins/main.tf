resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = "jenkins-system"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace_v1.jenkins.id

  depends_on = [
    kubernetes_namespace_v1.jenkins
  ]
}
