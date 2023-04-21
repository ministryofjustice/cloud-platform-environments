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
    "activities-api-dev",
    "calculate-release-dates-api-dev",
    "court-probation-dev",
    "hmpps-adjustments-dev",
    "hmpps-assessments-dev",
    "hmpps-community-accommodation-dev",
    "hmpps-complexity-of-need-staging",
    "hmpps-domain-event-logger-dev",
    "hmpps-incentives-dev",
    "hmpps-interventions-dev",
    "hmpps-manage-offences-api-dev",
    "hmpps-registers-dev",
    "hmpps-restricted-patients-api-dev",
    "hmpps-tier-dev",
    "hmpps-workload-dev",
    "make-recall-decision-dev",
    "offender-case-notes-dev",
    "offender-events-dev",
    "offender-management-staging",
    "offender-management-test",
    "offender-management-test2",
    "prisoner-offender-search-dev",
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

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}
