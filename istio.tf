# create kserve module
module "istio" {
  source = "./modules/istio-module"

  depends_on = [
    k3d_cluster.mlops_cluster,
  ]

  chart_version = local.istio.version
}
