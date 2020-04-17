/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

variable "cluster_state_bucket" {}

variable "namespace" {
  default = "contact-moj-development"
}

variable "domain" {
  default = "development.contact-moj.service.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}
