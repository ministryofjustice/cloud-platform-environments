variable "application" {
  default = "court-register"
}

variable "namespace" {
  default = "hmpps-domain-events-prod"
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
    "calculate-release-dates-api-prod",
    "court-probation-prod",
    "hmpps-assessments-prod",
    "hmpps-community-accommodation-prod",
    "hmpps-complexity-of-need-production",
    "hmpps-domain-event-logger-prod",
    "hmpps-incentives-prod",
    "hmpps-manage-adjudications-api-prod",
    "hmpps-interventions-prod",
    "hmpps-manage-offences-api-prod",
    "hmpps-registers-prod",
    "hmpps-restricted-patients-api-prod",
    "hmpps-tier-prod",
    "hmpps-workload-prod",
    "make-recall-decision-prod",
    "offender-case-notes-prod",
    "offender-management-production",
    "offender-events-prod",
    "prisoner-offender-search-prod",
    "visit-someone-in-prison-backend-svc-prod",
  ]
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

