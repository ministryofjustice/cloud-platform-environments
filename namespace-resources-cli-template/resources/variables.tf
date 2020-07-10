
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

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "{{ .BusinessUnit }}"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "{{ .GithubTeam }}"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "{{ .Environment }}"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "{{ .InfrastructureSupport }}"
}

variable "is-production" {
  default = "{{ .IsProduction }}"
}

variable "is-production" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "{{ .SlackChannel }}"
}
