# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow-pipelines" {
  source = "./modules/kubeflow-pipelines-module"

  depends_on = [
    k3d_cluster.zenml-cluster,
    module.istio,
  ]

  pipeline_version = local.kubeflow.version
  ingress_host     = "${local.kubeflow.ingress_host_prefix}.${module.istio.ingress-ip-address}.nip.io"
  tls_enabled      = false
}