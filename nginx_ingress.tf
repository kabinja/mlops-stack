module "nginx-ingress" {
  source = "./modules/nginx-ingress-module"

  count = 1

  # run only after the gke cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
  ]

  chart_version = local.nginx_ingress.version
}
