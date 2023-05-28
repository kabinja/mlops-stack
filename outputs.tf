output "artifact_store_id" {
  value = uuid()
}
output "artifact_store_flavor" {
  value = "s3"
}
output "artifact_store_name" {
  value = "k3d-minio-${random_string.cluster_id.result}"
}
output "artifact_store_configuration" {
  value = jsonencode({
    path          = "s3://${local.minio.zenml_minio_store_bucket}"
    key           = "${var.zenml-minio-store-access-key}"
    secret        = "${var.zenml-minio-store-secret-key}"
    client_kwargs = "{\"endpoint_url\":\"${module.minio_server.artifact_S3_Endpoint_URL}\", \"region_name\":\"us-east-1\"}"
  })
}
output "container_registry_id" {
  value = uuid()
}
output "container_registry_flavor" {
  value = "default"
}
output "container_registry_name" {
  value = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}"
}
output "container_registry_configuration" {
  value = jsonencode({
      uri = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
  })
}
output "orchestrator_id" {
  value =uuid()
}
output "orchestrator_flavor" {
  value = "kubeflow"
}
output "orchestrator_name" {
  value = "k3d-kubeflow-${random_string.cluster_id.result}"
}
output "orchestrator_configuration" {
  value = jsonencode({
    kubernetes_context = "k3d-${k3d_cluster.zenml-cluster.name}"
    synchronous        = true
    local              = true
    })
}
output "experiment_tracker_id" {
  value = uuid()
}
output "experiment_tracker_flavor" {
  value = "mlflow"
}
output "experiment_tracker_name" {
  value = "k3d-mlflow-${random_string.cluster_id.result}"
}
output "experiment_tracker_configuration" {
  value = jsonencode({
    tracking_uri      = module.mlflow.mlflow-tracking-URL
    tracking_username = var.mlflow-username
    tracking_password = var.mlflow-password
  })
}
output "model_deployer_id" {
  value = uuid()
}
output "model_deployer_flavor" {
  value = "seldon"
}
output "model_deployer_name" {
  value = "k3d-seldon-${random_string.cluster_id.result}"
}
output "model_deployer_configuration" {
  value = jsonencode({
    kubernetes_context   = "k3d-${k3d_cluster.zenml-cluster.name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio.ingress-ip-address}:${module.istio.ingress-port}"
    })
}
output "k3d-cluster-name" {
  value = k3d_cluster.zenml-cluster.name
}
output "container-registry-URI" {
  value = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
}
output "istio-ingress-hostname" {
  value = module.istio.ingress-ip-address
}
output "minio-console-URL" {
  value = module.minio_server.minio-console-URL
}
output "minio-endpoint-URL" {
  value = module.minio_server.artifact_S3_Endpoint_URL
}

output "kubeflow-pipelines-ui-URL" {
  value = module.kubeflow-pipelines.pipelines-ui-URL
}
output "mlflow-tracking-URL" {
  value = module.mlflow.mlflow-tracking-URL
}
output "mlflow-bucket" {
  value = (var.mlflow_minio_bucket == "") ? "mlflow-minio-${random_string.mlflow_bucket_suffix.result}" : ""
}
output "seldon-workload-namespace" {
  value       = local.seldon.workloads_namespace
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon-base-url" {
  value = module.istio.ingress-ip-address
}
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
