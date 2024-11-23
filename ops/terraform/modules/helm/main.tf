provider "helm" {
  kubernetes {
    host                   = var.kubeconfig["host"]
    cluster_ca_certificate = base64decode(var.kubeconfig["cluster_ca_certificate"])
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

resource "helm_release" "app" {
  name             = var.release_name
  repository       = var.chart_repository
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = var.values

  # Define dependencies and other advanced features
  depends_on = [aws_eks_cluster.this]
}
