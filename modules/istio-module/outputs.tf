output "ingress_ip_address" {
  value = data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.ip
}
output "ingress_hostname" {
  value = data.kubernetes_service.istio_ingress.status.0.load_balancer.0.ingress.0.hostname
}
output "ingress_port" {
  value = data.kubernetes_service.istio_ingress.spec.0.port.1.port
}
