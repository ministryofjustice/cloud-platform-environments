variable "environment_name" {
  default = "test"
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

// The following two variables are provided at runtime by the pipeline.
variable "vpc_name" {
}


variable "namespace" {
  default = "formbuilder-saas-test"
}

variable "db_instance_class" {
  default = "db.t3.large"
}
