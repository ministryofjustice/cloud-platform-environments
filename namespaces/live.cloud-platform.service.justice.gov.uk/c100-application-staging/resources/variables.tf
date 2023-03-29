variable "team_name" {
  default = "sustainingdevs"
}

variable "business_unit" {
  default = "HMCTS"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "sustainingaccountnotifications@hmcts.net"
}

variable "application" {
  default = "Apply to court about child arrangements"
}

variable "namespace" {
  default = "c100-application-staging"
}

variable "repo_name" {
  default = "c100-application"
}

# Database 

variable "db_engine_version" {
  default = "14.4"
}

variable "db_instance_class" {
  default = "db.t4g.small"
}

variable "db_engine_family" {
  default = "postgres14"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}
