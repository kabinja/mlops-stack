output "minio_server_endpoint" {
  value = var.ingress_host
}

output "minio_console_url" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_console_host}"
}

output "artifact_s3_endpoint_url" {
  value = "${var.tls_enabled ? "https" : "http"}://${var.ingress_host}"
}
