

variable "vpc_name" {
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
  default     = "book-a-prison-visit"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "prisonvisitsbooking@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "ask-visit-someone-in-prison"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}


variable "kubernetes_cluster" {}
