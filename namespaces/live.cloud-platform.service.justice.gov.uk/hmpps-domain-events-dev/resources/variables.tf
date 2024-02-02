variable "application" {
  default = "court-register"
}

variable "namespace" {
  default = "hmpps-domain-events-dev"
}

variable "vpc_name" {
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "additional_topic_clients" {
  description = "Create a dedicated access key and store it in a secret named 'hmpps-domain-events-topic' in each of the below namespaces."
  default = [
    "calculate-release-dates-api-dev",
    "court-probation-dev",
    "hmpps-activities-management-dev",
    "hmpps-adjustments-dev",
    "hmpps-assessments-dev",
    "hmpps-community-accommodation-dev",
    "hmpps-complexity-of-need-staging",
    "hmpps-education-and-work-plan-dev",
    "hmpps-education-employment-dev",
    "hmpps-incentives-dev",
    "hmpps-interventions-dev",
    "hmpps-manage-offences-api-dev",
    "hmpps-manage-adjudications-api-dev",
    "hmpps-non-associations-dev",
    "hmpps-registers-dev",
    "hmpps-tier-dev",
    "hmpps-workload-dev",
    "offender-case-notes-dev",
    "offender-management-staging",
    "offender-management-test",
    "offender-management-test2",
    "visit-someone-in-prison-backend-svc-dev",
  ]
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
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
