variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "hmpps-ecr-pullthrough-cache"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "hmpps-ecr-pullthrough-cache"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HMPPS"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "hmpps-sre"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Live Support"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "prod"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "hmpps_dev"
}
