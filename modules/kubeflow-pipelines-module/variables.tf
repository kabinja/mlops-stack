variable "pipeline_version" {
  type    = string
  default = "2.0.0-alpha.4"
}

variable "ingress_host" {
  type    = string
  default = ""
}

variable "tls_enabled" {
  type    = bool
  default = false
}