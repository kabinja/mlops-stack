# defining the providers required by the mlflow module
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.15.2"
    }
  }
  required_version = ">= 0.14.8"
}

