variable "team_name" {
  default = "sustainingdevs"
}

variable "environment_name" {
  default = "metabase"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "sustainingaccountnotifications@hmcts.net"
}

variable "slack_channel" {
  default = "#hmcts-sustaining-team"
}

variable "application" {
  default = "Metabase for Apply to court about child arrangements"
}

variable "namespace" {
  default = "c100-application-metabase"
}

// The following two variables are provided at runtime by the pipeline.
variable "vpc_name" {
}
