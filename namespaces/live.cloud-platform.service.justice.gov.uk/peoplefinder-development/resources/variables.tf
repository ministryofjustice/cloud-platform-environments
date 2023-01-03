/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-development"
}

variable "domain" {
  default = "development.peoplefinder.service.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "environment-name" {
  default = "development"
}

variable "eks_cluster_name" {
}
