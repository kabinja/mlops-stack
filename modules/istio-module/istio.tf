# create a namespace for istio resources
resource "kubernetes_namespace" "istio_namespace" {
  metadata {
    name = var.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

# istio_base creates the istio definitions that will be used going forward
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = var.chart_version

  # adding a dependency on the istio-namespace
  namespace = kubernetes_namespace.istio_namespace.metadata[0].name
}

# the istio daemon
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = helm_release.istio_base.repository # dependency on istio_base 
  chart      = "istiod"
  version    = var.chart_version

  namespace = kubernetes_namespace.istio_namespace.metadata[0].name
}

# creating the ingress gateway
resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = helm_release.istiod.repository
  chart      = "gateway"
  version    = var.chart_version

  # dependency on istio-ingress-ns
  namespace = kubernetes_namespace.istio_namespace.metadata[0].name
}

resource "kubernetes_ingress_class" "istio_ingress_class" {
  metadata {
    name = "istio"
  }
  spec {
    controller = "istio.io/ingress-controller"
  }
}

data "kubernetes_service" "istio_ingress" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = kubernetes_namespace.istio_namespace.metadata[0].name
  }
  depends_on = [
    resource.helm_release.istio_ingress
  ]
}
