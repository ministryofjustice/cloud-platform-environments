variable "environment_name" {
  default = "live"
}

variable "team_name" {
  default = "formbuilder"
}

variable "is_production" {
  default = "true"
}

variable "db_backup_retention_period" {
  default = "7"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-developers@digital.justice.gov.uk"
}

# The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "vpc_name" {
}


variable "namespace" {
  default = "formbuilder-saas-live"
}

variable "application" {
  default = "MOJ Forms Editor"
}

variable "zone_name" {
  default = "moj-forms-editor.service.justice.gov.uk"
}
