variable "namespace" {
  default = "hmpps-audit-dev"
}

variable "kubernetes_cluster" {}

variable "vpc_name" {}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "additional_audit_clients" {
  description = "Create a dedicated access key and stores it in a secret named 'hmpps-audit-queue' in each of the below namespaces."
  default = [
    "activities-api-dev",
    "hmpps-audit-dev",
    "hmpps-auth-dev",
    "hmpps-community-accommodation-dev",
    "hmpps-external-users-api-dev",
    "hmpps-historical-prisoner-api-dev",
    "hmpps-incentives-dev",
    "hmpps-manage-users-api-dev",
    "hmpps-prisoner-from-nomis-migration-dev",
    "hmpps-registers-dev",
    "hmpps-workload-dev",
    "make-recall-decision-dev",
    "visit-someone-in-prison-frontend-svc-dev",
    "visit-someone-in-prison-frontend-svc-staging",
  ]
}

variable "application" {
  description = "The name of the application"
  default     = "HMPPS-Audit-Service"
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

