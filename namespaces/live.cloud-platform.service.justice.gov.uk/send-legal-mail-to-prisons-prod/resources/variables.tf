
variable "cluster_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Send Legal Mail to Prisons"
}

variable "send_legal_mail_to_prisons_domain" {
  default = "send-legal-mail.prison.service.justice.gov.uk"
}

variable "check_rule39_mail_domain" {
  default = "check-rule39-mail.prison.service.justice.gov.uk"
}

variable "namespace" {
  default = "send-legal-mail-to-prisons-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "farsight-devs"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "prisoner_transactions_team"
}

variable "number_cache_clusters" {
  default = "2"
}

