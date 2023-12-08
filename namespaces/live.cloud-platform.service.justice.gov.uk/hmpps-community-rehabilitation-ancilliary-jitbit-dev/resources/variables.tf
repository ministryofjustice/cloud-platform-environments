

variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "hmpps community rehabilitation ancilliary jitbit"
}

variable "namespace" {
  default = "hmpps-community-rehabilitation-ancilliary-jitbit-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-cr-ancillary-jitbit-app-cloud-platform"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-webops@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "probation-webops"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

# Added during introduction of IRSA capability (IAM roles for service accounts)
variable "eks_cluster_name" {
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the ECR repository"
  default     = "false"
}
