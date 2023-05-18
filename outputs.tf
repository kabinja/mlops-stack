# if minio is enabled, set the artifact store outputs to the minio values
# otherwise, set the artifact store outputs to empty strings
output "artifact_store_id" {
  value = var.enable_minio ? uuid() : ""
}
output "artifact_store_flavor" {
  value = var.enable_minio ? "s3" : ""
}
output "artifact_store_name" {
  value = var.enable_minio ? "k3d-minio-${random_string.cluster_id.result}" : ""
}
output "artifact_store_configuration" {
  value = var.enable_minio ? jsonencode({
    path          = "s3://${local.minio.zenml_minio_store_bucket}"
    key           = "${var.zenml-minio-store-access-key}"
    secret        = "${var.zenml-minio-store-secret-key}"
    client_kwargs = "{\"endpoint_url\":\"${module.minio_server[0].artifact_S3_Endpoint_URL}\", \"region_name\":\"us-east-1\"}"
  }) : ""
}

# if container registry is enabled, set the container registry outputs to the k3d values
# otherwise, set the container registry outputs to empty strings
output "container_registry_id" {
  value = (var.enable_container_registry || var.enable_kubernetes ||
  var.enable_minio || var.enable_zenml) ? uuid() : ""
}
output "container_registry_flavor" {
  value = (var.enable_container_registry || var.enable_kubernetes ||
  var.enable_minio || var.enable_zenml) ? "default" : ""
}
output "container_registry_name" {
  value = (var.enable_container_registry || var.enable_kubernetes ||
  var.enable_minio || var.enable_zenml) ? "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}" : ""
}
output "container_registry_configuration" {
  value = (var.enable_container_registry || var.enable_kubernetes ||
    var.enable_minio || var.enable_zenml) ? jsonencode({
      uri = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
  }) : ""
}

# if kubeflow is enabled, set the orchestrator outputs to the kubeflow values
# if kubernetes is enabled, set the orchestrator outputs to the kubernetes values
# otherwise, set the orchestrator outputs to empty strings
output "orchestrator_id" {
  value = var.enable_kubernetes ? uuid() : ""
}
output "orchestrator_flavor" {
  value = "kubeflow"
}
output "orchestrator_name" {
  value = "k3d-kubeflow-${random_string.cluster_id.result}"
}
output "orchestrator_configuration" {
  value = jsonencode({
    kubernetes_context = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    synchronous        = true
    local              = true
    })
}

# if mlflow is enabled, set the experiment_tracker outputs to the mlflow values
# otherwise, set the experiment_tracker outputs to empty strings
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
    tracking_uri      = module.mlflow[0].mlflow-tracking-URL
    tracking_username = var.mlflow-username
    tracking_password = var.mlflow-password
  })
}

# if seldon is enabled, set the model_deployer outputs to the seldon values
# otherwise, set the model_deployer outputs to empty strings
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
    kubernetes_context   = "k3d-${k3d_cluster.zenml-cluster[0].name}"
    kubernetes_namespace = local.seldon.workloads_namespace
    base_url             = "http://${module.istio[0].ingress-ip-address}:${module.istio[0].ingress-port}"
    })
}

# output for the k3d cluster
output "k3d-cluster-name" {
  value = (var.enable_container_registry || var.enable_kubernetes ||
  var.enable_minio || var.enable_zenml) ? k3d_cluster.zenml-cluster[0].name : ""
}

# output for container registry
output "container-registry-URI" {
  value = "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
}

# nginx ingress hostname
output "nginx-ingress-hostname" {
  value = length(module.nginx-ingress) > 0 ? module.nginx-ingress[0].ingress-ip-address : null
}

# istio ingress hostname
output "istio-ingress-hostname" {
  value = length(module.istio) > 0 ? module.istio[0].ingress-ip-address : null
}

output "minio-console-URL" {
  value = (var.enable_minio) ? module.minio_server[0].minio-console-URL : null
}
output "minio-endpoint-URL" {
  value = (var.enable_minio) ? module.minio_server[0].artifact_S3_Endpoint_URL : null
}

output "kubeflow-pipelines-ui-URL" {
  value = module.kubeflow-pipelines[0].pipelines-ui-URL
}

# outputs for the MLflow tracking server
output "mlflow-tracking-URL" {
  value = module.mlflow[0].mlflow-tracking-URL
}
output "mlflow-bucket" {
  value = (var.mlflow_minio_bucket == "") ? "mlflow-minio-${random_string.mlflow_bucket_suffix.result}" : ""
}

# output for seldon model deployer
output "seldon-workload-namespace" {
  value       = local.seldon.workloads_namespace
  description = "The namespace created for hosting your Seldon workloads"
}
output "seldon-base-url" {
  value = module.istio[0].ingress-ip-address
}

# output the name of the stack YAML file created
output "stack-yaml-path" {
  value = local_file.stack_file.filename
}
