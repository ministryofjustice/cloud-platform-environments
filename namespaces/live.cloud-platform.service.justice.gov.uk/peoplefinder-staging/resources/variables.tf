/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-staging"
}

variable "domain" {
  default = "staging.peoplefinder.service.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "environment" {
  default = "staging"
}

variable "eks_cluster_name" {
}
