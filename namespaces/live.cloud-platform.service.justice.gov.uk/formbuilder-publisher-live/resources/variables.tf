# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "live"
}

variable "team_name" {
  default = "formbuilder"
}

variable "is_production" {
  default = "true"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-developers@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}


variable "namespace" {
  default = "formbuilder-publisher-live"
}

variable "business_unit" {
  default = "Platforms"
}
