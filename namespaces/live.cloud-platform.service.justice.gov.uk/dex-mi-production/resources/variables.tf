/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "dex-mi-production"
}


variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

