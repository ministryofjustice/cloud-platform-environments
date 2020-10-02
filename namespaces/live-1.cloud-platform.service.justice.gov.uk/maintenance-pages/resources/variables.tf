
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "MoJ Maintenance Pages"
}

variable "namespace" {
  default = "maintenance-pages"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "webops"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cloud-platform"
}

# DEPRECATED: snake-case variables are the default. The definitions below
# have been left in place until all code has been updated to use snake-case
# variable names.

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "webops"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cloud-platform"
}


variable "domains" {
  description = "List of domains to be put in maintenance"
  type        = any
  default = [
    "adminappeals.reports.tribunals.gov.uk",
    "administrativeappeals.decisions.tribunals.gov.uk",
    "carestandards.decisions.tribunals.gov.uk",
    "charity.decisions.tribunals.gov.uk",
    "cicap.decisions.tribunals.gov.uk",
    "claimsmanagement.decisions.tribunals.gov.uk",
    "consumercreditappeals.decisions.tribunals.gov.uk",
    "employmentappeals.decisions.tribunals.gov.uk",
    "estateagentappeals.decisions.tribunals.gov.uk",
    "financeandtax.decisions.tribunals.gov.uk",
    "immigrationservices.decisions.tribunals.gov.uk",
    "informationrights.decisions.tribunals.gov.uk",
    "landregistrationdivision.decisions.tribunals.gov.uk",
    "landschamber.decisions.tribunals.gov.uk",
    "maintenance-pages-demo.apps.live-1.cloud-platform.service.justice.gov.uk",
    "maintenance-pages-demo.apps.live-1.cloud-platform.service.justice.gov.uk",
    "phl.decisions.tribunals.gov.uk",
    "siac.decisions.tribunals.gov.uk",
    "sscs.venues.tribunals.gov.uk",
    "tax.decisions.tribunals.gov.uk",
    "taxandchancery_ut.decisions.tribunals.gov.uk",
    "transportappeals.decisions.tribunals.gov.uk"
  ]
}