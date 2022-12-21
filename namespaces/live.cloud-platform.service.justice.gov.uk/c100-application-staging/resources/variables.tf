variable "team_name" {
  default = "sustainingdevs"
}

variable "business_unit" {
  default = "HMCTS"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
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

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}
