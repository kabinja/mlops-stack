variable "namespace" {
  type    = string
  default = "mlflow"
}

variable "chart_version" {
  type    = string
  default = "0.7.19"
}

variable "htpasswd" {}

variable "ingress_host" {
  type    = string
  default = ""
}

variable "tls_enabled" {
  type    = bool
  default = true
}

variable "artifact_proxied_access" {
  type    = bool
  default = false
}

variable "artifact_S3" {
  type    = bool
  default = false
}
variable "artifact_S3_Bucket" {
  type    = string
  default = ""
}
variable "artifact_S3_Access_Key" {
  type    = string
  default = ""
}
variable "artifact_S3_Secret_Key" {
  type    = string
  default = ""
}
variable "artifact_s3_endpoint_url" {
  type    = string
  default = ""
}
