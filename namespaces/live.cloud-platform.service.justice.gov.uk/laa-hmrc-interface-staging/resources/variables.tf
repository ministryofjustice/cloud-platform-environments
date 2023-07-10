

variable "vpc_name" {
}

variable "kubernetes_cluster" {
}
variable "application" {
  description = "Name of Application you are deploying"
  default     = "laa-hmrc-interface-service-api"
}

variable "namespace" {
  default = "laa-hmrc-interface-staging"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "LAA"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-apply-for-legal-aid"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "apply-for-civil-legal-aid@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "apply-dev"
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
