# using the seldon module for creating a 
# seldon + istio deployment
module "seldon" {
  source = "./modules/seldon-module"

  # run only after the eks cluster and istio are set up
  depends_on = [
    k3d_cluster.mlops_cluster,
    module.istio
  ]

  # details about the seldon deployment
  chart_version = local.seldon.version
}

# the namespace where zenml will deploy seldon models
resource "kubernetes_namespace" "seldon-workloads" {
  metadata {
    name = local.seldon.workloads_namespace
  }
}

# add role to allow kubeflow to access seldon
#
# NOTE: the seldon zenml model deployer pipeline steps need to be able to create
# secrets, serviceaccounts, and Seldon deployments in the namespace where it
# will deploy models
resource "kubernetes_cluster_role_v1" "seldon" {
  metadata {
    name = "seldon-workloads"
    labels = {
      app = "zenml"
    }
  }

  rule {
    api_groups = ["machinelearning.seldon.io", ""]
    resources  = ["seldondeployments", "secrets", "serviceaccounts"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  depends_on = [
    module.seldon,
  ]
}

# assign role to kubeflow pipeline runner
resource "kubernetes_role_binding_v1" "kubeflow-seldon" {
  metadata {
    name      = "kubeflow-seldon"
    namespace = kubernetes_namespace.seldon-workloads.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.seldon.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "pipeline-runner"
    namespace = "kubeflow"
  }

  depends_on = [
    module.kubeflow_pipelines,
  ]
}

# assign role to kubernetes pipeline runner
resource "kubernetes_role_binding_v1" "k8s-seldon" {
  metadata {
    name      = "k8s-seldon"
    namespace = kubernetes_namespace.seldon-workloads.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.seldon.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.k8s-workloads.metadata[0].name
  }
}

resource "kubernetes_secret" "seldon-secret" {
  metadata {
    name      = var.seldon_secret_name
    namespace = kubernetes_namespace.seldon-workloads.metadata[0].name
    labels    = { app = "zenml" }
  }

  data = {
    RCLONE_CONFIG_S3_ACCESS_KEY_ID     = "${var.minio_store_access_key}"
    RCLONE_CONFIG_S3_ENDPOINT          = "${module.minio_server.artifact_s3_endpoint_url}"
    RCLONE_CONFIG_S3_PROVIDER          = "Minio"
    RCLONE_CONFIG_S3_ENV_PATH          = "false"
    RCLONE_CONFIG_S3_SECRET_ACCESS_KEY = "${var.minio_store_secret_key}"
    RCLONE_CONFIG_S3_TYPE              = "s3"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_namespace.seldon-workloads,
    module.minio_server,
  ]
}