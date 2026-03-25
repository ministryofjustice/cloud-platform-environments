variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "namespace" {
  type    = string
  default = "github-workflow-logging-dev"
}

variable "environment_name" {
  type    = string
  default = "development"
}

variable "team_name" {
  type    = string
  default = "operations-engineering"
}

variable "business_unit" {
  type    = string
  default = "Platforms"
}

variable "application" {
  type    = string
  default = "github-workflow-logging"
}

variable "is_production" {
  type    = string
  default = "false"
}

variable "infrastructure_support" {
  type    = string
  default = "operations-engineering@digital.justice.gov.uk"
}

variable "kubernetes_cluster" {
  description = "Injected by the CPE pipeline via TF_VAR_kubernetes_cluster"
  type        = string
}

variable "github_actions_repositories" {
  description = "GitHub repositories to publish Actions secrets/variables into"
  type        = list(string)
  default     = ["ministry-of-justice-github-analysis"]
}

variable "github_actions_environments" {
  description = "GitHub environments to scope secrets/variables to (empty = all environments)"
  type        = list(string)
  default     = []
}
