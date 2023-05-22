variable "application" {
  default = "court-register"
}

variable "namespace" {
  default = "hmpps-domain-events-preprod"
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
    "calculate-release-dates-api-preprod",
    "court-probation-preprod",
    "hmpps-assessments-preprod",
    "hmpps-community-accommodation-preprod",
    "hmpps-complexity-of-need-preprod",
    "hmpps-domain-event-logger-preprod",
    "hmpps-manage-adjudications-api-preprod",
    "hmpps-incentives-preprod",
    "hmpps-interventions-preprod",
    "hmpps-manage-offences-api-preprod",
    "hmpps-registers-preprod",
    "hmpps-restricted-patients-api-preprod",
    "hmpps-tier-preprod",
    "hmpps-workload-preprod",
    "make-recall-decision-preprod",
    "offender-case-notes-preprod",
    "offender-events-preprod",
    "offender-management-preprod",
    "prisoner-offender-search-preprod",
    "visit-someone-in-prison-backend-svc-preprod",
  ]
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
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

