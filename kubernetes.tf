# a default (non-aliased) provider configuration for "kubernetes"
provider "kubernetes" {
  host = k3d_cluster.mlops_cluster.credentials.0.host
  client_certificate = k3d_cluster.mlops_cluster.credentials.0.client_certificate
  client_key = k3d_cluster.mlops_cluster.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.mlops_cluster.credentials.0.cluster_ca_certificate
}

provider "kubectl" {
  host = k3d_cluster.mlops_cluster.credentials.0.host
  client_certificate = k3d_cluster.mlops_cluster.credentials.0.client_certificate
  client_key = k3d_cluster.mlops_cluster.credentials.0.client_key
  cluster_ca_certificate = k3d_cluster.mlops_cluster.credentials.0.cluster_ca_certificate
}

# the namespace where zenml will run kubernetes orchestrator workloads
resource "kubernetes_namespace" "k8s-workloads" {
  metadata {
    name = local.k3d.workloads_namespace
  }
  depends_on = [
    k3d_cluster.mlops_cluster,
  ]
}