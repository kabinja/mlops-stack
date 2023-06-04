resource "random_string" "cluster_id" {
  length  = 6
  special = false
  upper   = false
}

resource "k3d_registry" "mlops_registry" {
  # IMPORTANT: the registry name must contain the `.localhost` suffix because
  # this is the only way to make it accessible using the same hostname from
  # both the host and from inside the cluster. K3D automatically maps the
  # `k3d-<registry-name>.localhost` hostname to localhost outside the cluster,
  # and inside the cluster it maps `k3d-<registry-name>` to the registry
  # container IP address. If the cluster name contains the `.localhost` suffix,
  # then the `k3d-<registry-name>` hostname can also be used to access the
  # registry from the host.
  name  = "${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost"
  image = "docker.io/registry:2"

  port {
    host_port = local.k3d_registry.port
    host_ip   = "0.0.0.0"
  }
}

resource "k3d_cluster" "mlops_cluster" {
  name    = "${local.k3d.cluster_name}-${random_string.cluster_id.result}"
  servers = 1
  agents  = 2

  kube_api {
    host    = local.k3d_kube_api.host
    host_ip = "127.0.0.1"
  }

  image = local.k3d.image
  registries {
    use = ["${k3d_registry.mlops_registry.name}:${k3d_registry.mlops_registry.port[0].host_port}"]
  }

  port {
    host_port      = 9000
    container_port = 9000
    node_filters = [
      "loadbalancer",
    ]
  }
  k3d {
    disable_load_balancer = false
    disable_image_volume  = false
  }

  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = true
  }

  k3s {
    extra_args {
      arg          = "--disable=traefik"
      node_filters = ["server:*"]
    }
  }

  depends_on = [
    k3d_registry.mlops_registry,
  ]
}
