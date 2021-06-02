variable "team_name" {
  default = "sustainingdevs"
}

variable "environment-name" {
  default = "metabase"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
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
variable "cluster_name" {
}


