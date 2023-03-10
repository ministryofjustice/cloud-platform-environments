variable "namespace" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "business_unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "prod"
}

variable "is_production" {
  default = "true"
}

variable "domain" {
  default = "claim-criminal-injuries-compensation.service.justice.gov.uk"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email"
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backup jobs. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

# For Push gateway
variable "service_monitor" {
  description = "If true, prometheus will automatically scrape"
  default     = true
}
