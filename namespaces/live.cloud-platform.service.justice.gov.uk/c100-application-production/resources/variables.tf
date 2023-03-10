variable "team_name" {
  default = "sustainingdevs"
}

variable "business_unit" {
  default = "HMCTS"
}

variable "environment-name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "sustainingaccountnotifications@hmcts.net"
}

variable "application" {
  default = "Apply to court about child arrangements"
}

variable "namespace" {
  default = "c100-application-production"
}

# The following variable is provided at runtime by the pipeline.
variable "vpc_name" {
}
