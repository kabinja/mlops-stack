output "mlflow_tracking_url" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}
