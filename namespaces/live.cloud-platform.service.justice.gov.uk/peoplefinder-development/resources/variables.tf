/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

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
