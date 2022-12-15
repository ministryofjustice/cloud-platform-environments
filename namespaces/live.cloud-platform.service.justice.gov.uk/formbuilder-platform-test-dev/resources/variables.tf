variable "environment-name" {
  default = "test-dev"
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

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}


variable "namespace" {
  default = "formbuilder-platform-test-dev"
}

variable "db_instance_class" {
  default = "db.m6g.large"
}
