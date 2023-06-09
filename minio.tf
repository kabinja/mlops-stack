
module "minio_server" {
  source = "./modules/minio-module"

  # run only after the eks cluster is set up
  depends_on = [
    k3d_cluster.mlops_cluster,
    module.istio,
  ]

  # details about the mlflow deployment
  minio_storage_size   = local.minio.storage_size
  minio_access_key     = var.minio_store_access_key
  minio_secret_key     = var.minio_store_secret_key
  ingress_host         = "${local.minio.ingress_host_prefix}.${module.istio.ingress_ip_address}.nip.io"
  ingress_console_host = "${local.minio.ingress_console_host_prefix}.${module.istio.ingress_ip_address}.nip.io"
  tls_enabled          = false
}

provider "minio" {
  minio_server = "localhost:9000"
  minio_user = var.minio_store_access_key
  minio_password = var.minio_store_secret_key
  minio_ssl = false
}
# Create a bucket for ZenML to use
resource "minio_s3_bucket" "mlops_bucket" {
  bucket = local.minio.zenml_minio_store_bucket
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.istio,
  ]
}