# Export Terraform output variable values to a ZenML test framework
# configuration file that can be used to run ZenML integration tests
# against the deployed MLOps stack.
resource "local_file" "test_framework_cfg_file" {
  content  = <<-ADD
requirements:

%{if var.enable_container_registry}
  - name: k3d-container-registry-${random_string.cluster_id.result}
    description: >-
      Local K3D container registry.
    system_tools:
      - docker
    stacks:
      - name: k3d-${random_string.cluster_id.result}
        type: container_registry
        flavor: default
        configuration:
          uri: "k3d-${local.k3d_registry.name}-${random_string.cluster_id.result}.localhost:${local.k3d_registry.port}"
%{endif}

%{if var.enable_kubernetes}
  - name: k3d-kubernetes-${random_string.cluster_id.result}
    description: >-
      K3D cluster that can be used as a kubernetes orchestrator.
    system_tools:
      - docker
      - kubectl
    capabilities:
      synchronized: true
    stacks:
      - name: k3d-kubernetes-${random_string.cluster_id.result}
        type: orchestrator
        flavor: kubernetes
        containerized: true
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster[0].name}"
          synchronous: true
          kubernetes_namespace: "${local.k3d.workloads_namespace}"
          local: true
%{endif}

  - name: k3d-kubeflow-${random_string.cluster_id.result}
    description: >-
      Kubeflow running in a local K3D cluster.
    system_tools:
      - docker
      - kubectl
    capabilities:
      synchronized: true
    stacks:
      - name: k3d-kubeflow-${random_string.cluster_id.result}
        type: orchestrator
        flavor: kubeflow
        containerized: true
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster[0].name}"
          synchronous: true
          local: true

%{if var.enable_minio}
  - name: k3d-minio-artifact-store-${random_string.cluster_id.result}
    description: >-
      Minio artifact store running in a local K3D cluster.
    stacks:
      - name: k3d-minio-${random_string.cluster_id.result}
        type: artifact_store
        flavor: s3
        configuration:
          path: "s3://${local.minio.zenml_minio_store_bucket}"
          key: "${var.zenml-minio-store-access-key}"
          secret: "${var.zenml-minio-store-secret-key}"
          client_kwargs: '{"endpoint_url":"${module.minio_server[0].artifact_S3_Endpoint_URL}", "region_name":"us-east-1"}'
%{endif}

  - name: k3d-mlflow-${random_string.cluster_id.result}
    description: >-
      MLFlow deployed in a local K3D cluster.
    stacks: 
      - name: k3d-mlflow-${random_string.cluster_id.result}
        type: experiment_tracker
        flavor: mlflow
        configuration:
          tracking_uri: "${module.mlflow[0].mlflow-tracking-URL}"
          tracking_username: "${var.mlflow-username}"
          tracking_password: "${var.mlflow-password}"

  - name: k3d-seldon-${random_string.cluster_id.result}
    description: >-
      Seldon Core deployed in a local K3D cluster.
    system_tools:
      - kubectl
    stacks:
      - name: k3d-seldon-${random_string.cluster_id.result}
        type: model_deployer
        flavor: seldon
        configuration:
          kubernetes_context: "k3d-${k3d_cluster.zenml-cluster[0].name}"
          kubernetes_namespace: "${local.seldon.workloads_namespace}"
          base_url:  "http://${module.istio[0].ingress-ip-address}"
          kubernetes_secret_name: "${var.seldon-secret-name}"

environments:

  - name: default-k3d-local-orchestrator
    description: >-
      Default deployment with local orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - local-secrets-manager
      - k3d-seldon-${random_string.cluster_id.result}
    mandatory_requirements:
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}
    capabilities:
      synchronized: true

%{if var.enable_kubernetes} 
  - name: default-k3d-kubernetes-orchestrator
    description: >-
      Default deployment with K3D kubernetes orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - k3d-seldon-${random_string.cluster_id.result}
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubernetes-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}
%{endif}

  - name: default-k3d-kubeflow-orchestrator
    description: >-
      Default deployment with K3D kubeflow orchestrator and other
      K3D provided or local components.
    deployment: default
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - k3d-seldon-${random_string.cluster_id.result}
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubeflow-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}

    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-local-orchestrator
    description: >-
      Local server deployment with local orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - local-secrets-manager
      - k3d-seldon-${random_string.cluster_id.result}
    mandatory_requirements:
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}
    capabilities:
      synchronized: true

    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.

%{if var.enable_kubernetes}
  - name: local-server-k3d-kubernetes-orchestrator
    description: >-
      Local server deployment with K3D kubernetes orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - k3d-seldon-${random_string.cluster_id.result}
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubernetes-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}
%{endif}

    # IMPORTANT: don't use this with pytest auto-provisioning. Running forked
    # daemons in pytest leads to serious issues because the whole test process
    # is forked. As a workaround, the deployment can be started separately,
    # before pytest is invoked.
  - name: local-server-k3d-kubeflow-orchestrator
    description: >-
      Local server deployment with K3D kubeflow orchestrator and other
      K3D provided or local components.
    deployment: local-server
    requirements:
      - data-validators
      - k3d-mlflow-${random_string.cluster_id.result}
      - k3d-seldon-${random_string.cluster_id.result}
      - local-secrets-manager
    mandatory_requirements:
      - k3d-kubeflow-${random_string.cluster_id.result}
      - k3d-container-registry-${random_string.cluster_id.result}
%{if var.enable_minio}
      - k3d-minio-artifact-store-${random_string.cluster_id.result}
%{endif}
    ADD
  filename = "./k3d_test_framework_cfg.yaml"
}