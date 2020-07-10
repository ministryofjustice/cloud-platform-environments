
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  default = "{{ .Application }}"
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
  default     = "{{ .TeamName }}"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "{{ .Environment }}"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "{{ .InfrastructureSupport }}"
}

variable "is-production" {
  default = "false"
}

