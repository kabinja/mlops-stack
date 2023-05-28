# defining the providers for the recipe module
terraform {
  required_providers {
    k3d = {
      source = "pvotal-tech/k3d"
      version = "0.0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }

    minio = {
      source  = "aminueza/minio"
      version = "1.15.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.4"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.3.1"
    }
  }

  required_version = ">= 0.14.8"
}