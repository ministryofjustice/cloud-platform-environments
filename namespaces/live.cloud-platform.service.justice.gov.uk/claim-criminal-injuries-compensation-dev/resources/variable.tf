variable "namespace" {
  default = "claim-criminal-injuries-compensation-dev"
}

variable "business_unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-dev"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "dev"
}

variable "is_production" {
  default = "false"
}

variable "domain" {
  default = "dev.claim-criminal-injuries-compensation.service.justice.gov.uk"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email"
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backup jobs. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

variable "service_monitor" {
  description = "If true, prometheus will automatically scrape"
  default     = true
}
