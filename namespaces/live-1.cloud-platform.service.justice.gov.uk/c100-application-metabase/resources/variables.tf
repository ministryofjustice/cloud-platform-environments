variable "team_name" {
  default = "family-justice"
}

variable "environment-name" {
  default = "metabase"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "Family Justice: family-justice-team@digital.justice.gov.uk"
}

variable "slack_channel" {
  default = "#cross_justice_team"
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

variable "cluster_state_bucket" {
}

