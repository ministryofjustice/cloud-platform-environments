variable "kubernetes_cluster" {}

variable "vpc_name" {}

variable "eks_cluster_name" {}

variable "application" {
  default = "HMPPS Incident Reporting Service"
}

variable "namespace" {
  default = "hmpps-incident-reporting-prod"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "hmpps-incident-reporting"
}

variable "environment" {
  default = "production"
}

variable "infrastructure_support" {
  default = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  default = "incident-reporting-service-dev"
}

variable "rds_backup_window" {
  default = "22:00-23:59"
}

variable "rds_maintenance_window" {
  default = "sun:00:00-sun:03:00"
}

variable "github_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "github_token" {
  type    = string
  default = ""
}
variable "kubernetes_cluster" {}
