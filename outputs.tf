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
    key           = "${var.minio_store_access_key}"
    secret        = "${var.minio_store_secret_key}"
    client_kwargs = "{\"endpoint_url\":\"${module.minio_server.artifact_s3_endpoint_url}\", \"region_name\":\"us-east-1\"}"
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
    kubernetes_context = "k3d-${k3d_cluster.mlops_cluster.name}"
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
  value = "k3d_mlflow_${random_string.cluster_id.result}"
}
output "experiment_tracker_configuration" {
  value = jsonencode({
    tracking_uri      = module.mlflow.mlflow_tracking_url
    tracking_username = var.mlflow_username
    tracking_password = var.mlflow_password
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
    kubernetes_context   = "k3d-${k3d_cluster.mlops_cluster.name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio.ingress_ip_address}:${module.istio.ingress_port}"
    })
}
output "k3d_cluster_name" {
  value = k3d_cluster.mlops_cluster.name
}
output "container_registry_uri" {
  value = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
}
output "istio_ingress_hostname" {
  value = module.istio.ingress_ip_address
}
output "minio_console_url" {
  value = module.minio_server.minio_console_url
}
output "minio_endpoint_url" {
  value = module.minio_server.artifact_s3_endpoint_url
}

output "kubeflow_pipelines_ui_url" {
  value = module.kubeflow_pipelines.pipelines_ui_url
}
output "mlflow_tracking_url" {
  value = module.mlflow.mlflow_tracking_url
}
output "mlflow_bucket" {
  value = (var.mlflow_minio_bucket == "") ? "mlflow-minio-${random_string.mlflow_bucket_suffix.result}" : ""
}
output "seldon_workload_namespace" {
  value       = local.seldon.workloads_namespace
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon_base_url" {
  value = module.istio.ingress_ip_address
}
output "stack_yaml_path" {
  value = local_file.stack_file.filename
}
