# config values to use across the module
locals {
  k3d = {
    cluster_name        = "mlops-cluster"
    image               = "rancher/k3s:v1.24.4-k3s1"
    local_stores_path   = ""
    workloads_namespace = "zenml-workloads-k8s"
  }

  k3d_registry = {
    name = "zenml-registry"
    port = "5001"
  }

  k3d_kube_api = {
    host = "0.0.0.0"
  }

  minio = {
    storage_size                = "2Gi"
    zenml_minio_store_bucket    = "zenml-minio-store"
    ingress_host_prefix         = "minio"
    ingress_console_host_prefix = "minio-console"
  }

  istio = {
    version = "1.14.1"
  }

  kubeflow = {
    version             = "1.8.5"
    ingress_host_prefix = "kubeflow"
  }

  mlflow = {
    version = "0.7.13"
    # if not set, you'll need to pass the minio credentials to the pipeline/step.
    # E.g. when running with the default local orchestrator:
    #
    #  AWS_ACCESS_KEY_ID=zenml AWS_SECRET_ACCESS_KEY=supersafepassword MLFLOW_S3_ENDPOINT_URL="http://minio.172.24.0.3.nip.io" python run.py
    #
    artifact_Proxied_Access = "true"
    ingress_host_prefix     = "mlflow"
  }

  seldon = {
    version              = "1.15.0"
    name                 = "seldon"
    namespace            = "seldon-system"
    workloads_namespace  = "zenml-workloads-seldon"
    service_account_name = "seldon"
  }

  tags = {
    "managedBy"   = "terraform"
    "environment" = "dev"
  }
}