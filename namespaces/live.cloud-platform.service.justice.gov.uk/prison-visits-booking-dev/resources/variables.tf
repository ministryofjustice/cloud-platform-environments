
variable "vpc_name" {
}

variable "environment_name" {
  default = "dev"
}

variable "environment" {
  default = "dev"
}

variable "team_name" {
  default = "hmpps-prison-visits-booking-devs"
}

variable "is_production" {
  default = "false"
}

variable "namespace" {
  default = "prison-visits-booking-dev"
}

variable "infrastructure_support" {
  default = "pvb-technical-support@digital.justice.gov.uk"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "github_owner" {
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

variable "application" {
  default     = "prison-visits-booking-dev"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "kubernetes_cluster" {}
