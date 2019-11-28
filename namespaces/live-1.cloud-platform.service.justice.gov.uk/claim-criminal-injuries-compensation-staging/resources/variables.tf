variable "namespace" {
  default = "claim-criminal-injuries-compensation-staging"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-staging"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

