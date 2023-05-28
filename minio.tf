
module "minio_server" {
  source = "./modules/minio-module"

  # run only after the eks cluster is set up
  depends_on = [
    k3d_cluster.zenml-cluster,
    module.istio,
  ]

  # details about the mlflow deployment
  minio_storage_size   = local.minio.storage_size
  minio_access_key     = var.zenml-minio-store-access-key
  minio_secret_key     = var.zenml-minio-store-secret-key
  ingress_host         = "${local.minio.ingress_host_prefix}.${module.istio.ingress-ip-address}.nip.io"
  ingress_console_host = "${local.minio.ingress_console_host_prefix}.${module.istio.ingress-ip-address}.nip.io"
  tls_enabled          = false
}

provider "minio" {
  # The Minio server endpoint.
  # NOTE: do NOT add an http:// or https:// prefix!
  # Set the `ssl = true/false` setting instead.
  minio_server = "localhost:9000"
  # Specify your minio user access key here.
  minio_user = var.zenml-minio-store-access-key
  # Specify your minio user secret key here.
  minio_password = var.zenml-minio-store-secret-key
  # If true, the server will be contacted via https://
  minio_ssl = false
}
# Create a bucket for ZenML to use
resource "minio_s3_bucket" "zenml_bucket" {

  bucket        = local.minio.zenml_minio_store_bucket
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.istio,
  ]
}