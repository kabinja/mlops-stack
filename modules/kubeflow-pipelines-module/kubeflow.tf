# set up kubeflow pipelines
resource "null_resource" "kubeflow" {
  triggers = {
    pipeline_version = var.pipeline_version
  }

  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=${self.triggers.pipeline_version}&timeout=5m'"
  }
  provisioner "local-exec" {
    command = "kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io"
  }
  provisioner "local-exec" {
    command = "kubectl apply -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=${self.triggers.pipeline_version}&timeout=5m'"
  }

  # destroy-time provisioners
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=${self.triggers.pipeline_version}'"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -k 'github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=${self.triggers.pipeline_version}'"
  }
}

# Create Gateway and VirtualService if istio is enabled
resource "kubectl_manifest" "kubeflow-ui-gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: zenml-kubeflow-ui-gateway
  namespace: kubeflow
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      name: http
      number: 80
      protocol: HTTP
    hosts:
    - '*'
  %{if var.tls_enabled}
    tls:
      httpsRedirect: false
  - port:
      name: https
      number: 443
      protocol: HTTPS
    hosts:
    - '*'
    tls:
      mode: SIMPLE # enables HTTPS on this port
      credentialName: kubeflow-ui-tls
    %{endif}
YAML    
  depends_on = [
    null_resource.kubeflow
  ]
}

resource "kubectl_manifest" "kubeflow-ui-virtualservice" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kubeflow-ui-virtualservice
  namespace: kubeflow
spec:
  hosts:
  - ${var.ingress_host}
  gateways:
  - zenml-kubeflow-ui-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: ml-pipeline-ui
        port:
          number: 80
YAML    
  depends_on = [
    null_resource.kubeflow
  ]
}
