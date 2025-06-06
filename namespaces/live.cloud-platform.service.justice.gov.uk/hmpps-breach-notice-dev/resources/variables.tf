variable "kubernetes_cluster" {
}


variable "vpc_name" {
}


variable "application" {
  default = "hmpps-breach-notice"
}

variable "namespace" {
  default = "hmpps-breach-notice-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "unilink"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-unilink-delius@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
}

variable "domain_events_topic_name" {
  default = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}