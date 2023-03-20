# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "live-dev"
}

variable "team_name" {
  default = "formbuilder"
}

variable "db_backup_retention_period_submitter" {
  default = "2"
}

variable "db_backup_retention_period_user_datastore" {
  default = "2"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-developers@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

variable "namespace" {
  default = "formbuilder-platform-live-dev"
}

variable "db_instance_class" {
  default = "db.m6g.large"
}

variable "business_unit" {
  default = "Platforms"
}
