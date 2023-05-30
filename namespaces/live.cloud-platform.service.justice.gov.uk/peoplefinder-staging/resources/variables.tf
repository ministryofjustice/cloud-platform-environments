/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-staging"
}

variable "business_unit" {
  default = "Central Digital"
}

variable "application" {
  default = "peoplefinder"
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

variable "infrastructure_support" {
  default = "people-finder-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "peoplefinder"
}

variable "eks_cluster_name" {
}
