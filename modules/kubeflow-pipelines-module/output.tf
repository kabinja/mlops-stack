output "pipelines_ui_url" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}
