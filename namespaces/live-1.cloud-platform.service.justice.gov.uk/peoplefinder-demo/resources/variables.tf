/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

variable "cluster_state_bucket" {}

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
