variable "team_name" {
  default = "imran-test"
}

variable "environment-name" {
  default = "dev"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "test"
}

variable "application" {
  default = "Apply to court about child arrangements"
}

variable "namespace" {
  default = "team-resources"
}

variable "repo_name" {
  default = "test"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

