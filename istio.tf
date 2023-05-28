# create kserve module
module "istio" {
  source = "./modules/istio-module"

  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.istio.version
}
