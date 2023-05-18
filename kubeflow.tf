# using the kubeflow pipelines module to create a kubeflow pipelines deployment
module "kubeflow-pipelines" {
  source = "./modules/kubeflow-pipelines-module"

  count = 1

  depends_on = [
    k3d_cluster.zenml-cluster,
    module.istio,
  ]

  pipeline_version = local.kubeflow.version
  ingress_host     = "${local.kubeflow.ingress_host_prefix}.${module.istio[0].ingress-ip-address}.nip.io"
  tls_enabled      = false
  istio_enabled    = true
}