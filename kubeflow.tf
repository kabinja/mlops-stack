# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow_pipelines" {
  source = "./modules/kubeflow-pipelines-module"

  depends_on = [
    k3d_cluster.mlops_cluster,
    module.istio,
    module.minio_server,
    module.mlflow
  ]

  pipeline_version = local.kubeflow.version
  ingress_host     = "${local.kubeflow.ingress_host_prefix}.${module.istio.ingress_ip_address}.nip.io"
  tls_enabled      = false
}