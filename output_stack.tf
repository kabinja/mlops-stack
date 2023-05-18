# Export Terraform output variable values to a stack yaml file 
# that can be consumed by zenml stack import
resource "local_file" "stack_file" {
  content  = <<-ADD
    # Stack configuration YAML
    # Generated by the K3D MLOps stack recipe.
    zenml_version: ${var.zenml-version}
    stack_name: k3d_minimal_${replace(substr(timestamp(), 0, 16), ":", "_")}
    components:
      artifact_store:
        id: ${uuid()}
        flavor: s3
        name: k3d-minio-${random_string.cluster_id.result}
        configuration:
          path: "s3://${local.minio.zenml_minio_store_bucket}"
          key: "${var.zenml-minio-store-access-key}"
          secret: "${var.zenml-minio-store-secret-key}"
          client_kwargs: '{"endpoint_url":"${module.minio_server[0].artifact_S3_Endpoint_URL}", "region_name":"us-east-1"}'
      container_registry:
        id: ${uuid()}
        flavor: default
        name: k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}
        configuration:
          uri: "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
      orchestrator:
        id: ${uuid()}
        flavor: kubeflow
        name: k3d-kubeflow-${random_string.cluster_id.result}
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster[0].name}"
          synchronous: true
          local: true
      experiment_tracker:
        id: ${uuid()}
        flavor: mlflow
        name: k3d-mlflow-${random_string.cluster_id.result}
        configuration:
          tracking_uri: "${module.mlflow[0].mlflow-tracking-URL}"
          tracking_username: "${var.mlflow-username}"
          tracking_password: "${var.mlflow-password}"
      model_deployer:
        id: ${uuid()}
        flavor: seldon
        name: k3d-seldon-${random_string.cluster_id.result}
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster[0].name}"
          kubernetes_namespace: "${local.seldon.workloads_namespace}"
          base_url:  "http://${module.istio[0].ingress-ip-address}"
          kubernetes_secret_name: "${var.seldon-secret-name}"
      secrets_manager:
        id: ${uuid()}
        flavor: local
        name: k3d-secrets-manager-${random_string.cluster_id.result}
        configuration: {}
    ADD
  filename = "./k3d_stack_${replace(substr(timestamp(), 0, 16), ":", "_")}.yaml"
}