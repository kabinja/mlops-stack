# using the mlflow module to create an mlflow deployment
module "mlflow" {
  source = "./modules/mlflow-module"

  depends_on = [
    k3d_cluster.zenml-cluster,
    module.istio,
    module.minio_server,
  ]

  # details about the mlflow deployment
  chart_version            = local.mlflow.version
  ingress_host             = "${local.mlflow.ingress_host_prefix}.${module.istio.ingress-ip-address}.nip.io"
  tls_enabled              = false
  htpasswd                 = "${var.mlflow-username}:${htpasswd_password.hash.apr1}"
  artifact_Proxied_Access  = local.mlflow.artifact_Proxied_Access
  artifact_S3              = "true"
  artifact_S3_Bucket       = minio_s3_bucket.mlflow_bucket.bucket
  artifact_S3_Access_Key   = var.zenml-minio-store-access-key
  artifact_S3_Secret_Key   = var.zenml-minio-store-secret-key
  artifact_S3_Endpoint_URL = module.minio_server.artifact_S3_Endpoint_URL
}

resource "htpasswd_password" "hash" {
  password = var.mlflow-password
}

resource "random_string" "mlflow_bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create a bucket for MLFlow to use
resource "minio_s3_bucket" "mlflow_bucket" {
  bucket        = "mlflow-minio-${random_string.mlflow_bucket_suffix.result}"
  force_destroy = true

  depends_on = [
    module.minio_server,
    module.istio,
  ]
}