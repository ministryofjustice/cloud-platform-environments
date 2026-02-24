variable "application" {
  default     = "HMPPS-Audit-Service"
}

variable "namespace" {
  default = "hmpps-audit-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Foundations"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-auth-audit-registers"
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

variable "github_team" {
  description = "The slug of the GitHub team associated with the "
  type        = string
  default     = "haha-audit-dev"
}

variable "approved_prisoner_audit_clients" {
  type    = list(string)
  default = ["hmpps-launchpad-dev"]


  # Validate the approved clients against keys stored in the k8s secret.
  validation {
    condition = alltrue([
      for client in var.approved_prisoner_audit_clients :
      contains(keys(data.kubernetes_secret.approved_prisoner_audit_client_arns.data), client)
    ])
    error_message = "The approved client list does not match the keys in the approved_prisoner_audit_client_arns Kubernetes secret."
  }
}


variable "kubernetes_cluster" {}

variable "eks_cluster_name" {}

variable "vpc_name" {}