variable "application" {
  default = "MOJ Forms Product Page"
}

variable "namespace" {
  default = "formbuilder-product-page-prod"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "formbuilder"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "zone_name" {
  default = "moj-online.service.justice.gov.uk"
}

variable "zone_name_new" {
  default = "moj-forms.service.justice.gov.uk"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "form-builder-developers@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}
