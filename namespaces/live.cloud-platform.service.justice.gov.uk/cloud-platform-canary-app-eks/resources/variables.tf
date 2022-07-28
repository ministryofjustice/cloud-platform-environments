
variable "cluster_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Canary application to monitor cluster uptime"
}

variable "namespace" {
  default = "cloud-platform-canary-app-eks"
}

variable "host_name" {
  default = "canary.apps.live.cloud-platform.service.justice.gov.uk"
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
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cloud-platform"
}
