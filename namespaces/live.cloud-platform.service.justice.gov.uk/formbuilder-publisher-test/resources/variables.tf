# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "test"
}

variable "team_name" {
  default = "formbuilder"
}

variable "namespace" {
  default = "formbuilder-publisher-test"
}

variable "is_production" {
  default = "false"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

variable "business_unit" {
  default = "Platforms"
}
