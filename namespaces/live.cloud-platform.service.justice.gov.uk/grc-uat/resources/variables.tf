variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Gender Recognition App"
}

variable "namespace" {
  default = "grc-uat"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMCTS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "pet"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "uat"
}

variable "logging_enabled" {
  default = true
}

variable "log_path" {
  default = "logs/"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "pet@hmcts.net"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "pet"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
}
