
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "{{ .Application }}"
}

variable "namespace" {
  default = "{{ .Namespace }}"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "{{ .BusinessUnit }}"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "{{ .GithubTeam }}"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "{{ .Environment }}"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "{{ .InfrastructureSupport }}"
}

variable "is_production" {
  default = "{{ .IsProduction }}"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "{{ .SlackChannel }}"
}

# DEPRECATED: snake-case variables are the default. The definitions below
# have been left in place until all code has been updated to use snake-case
# variable names.

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "{{ .BusinessUnit }}"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "{{ .GithubTeam }}"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "{{ .InfrastructureSupport }}"
}

variable "is-production" {
  default = "{{ .IsProduction }}"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "{{ .SlackChannel }}"
}

