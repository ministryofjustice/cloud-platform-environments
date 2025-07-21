variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS ARNS risk actuarial"
}

variable "namespace" {
<<<<<<< HEAD:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-prod/resources/variables.tf
  default = "hmpps-arns-risk-actuarial-prod"
=======
  default = "hmpps-arns-risk-actuarial-preprod"
>>>>>>> f706173aa0f1e0b9ce10a95727a418e1523d5e62:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-preprod/resources/variables.tf
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-assessments-devs"
}

####################################################################################################################
### Change this environment to the environment name corresponding to this namespace (as per helm/values-ENV.dev) ###
variable "environment" {
  description = "The type of environment you're deploying to."
<<<<<<< HEAD:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-prod/resources/variables.tf
  default     = "prod"
=======
  default     = "preprod"
>>>>>>> f706173aa0f1e0b9ce10a95727a418e1523d5e62:namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-arns-risk-actuarial-preprod/resources/variables.tf
}
####################################################################################################################

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "assess-risks-and-needs@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "arns-risk-actuarial-team"
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
