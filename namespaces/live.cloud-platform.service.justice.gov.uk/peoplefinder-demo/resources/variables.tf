/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-demo"
}

variable "domain" {
  default = "demo.peoplefinder.service.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "environment-name" {
  default = "demo"
}

variable "eks_cluster_name" {
}
