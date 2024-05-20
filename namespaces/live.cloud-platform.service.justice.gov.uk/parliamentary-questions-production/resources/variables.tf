variable "application" {
  default = "Parliamentary Questions Tracker"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HQ"
}

variable "db_backup_retention_period" {
  default = "7"
}

variable "environment-name" {
  default = "production"
}

variable "infrastructure_support" {
  default = "Tactical Products Team: pqsupport@digital.justice.gov.uk"
}

variable "is_production" {
  default = true
}

variable "namespace" {
  default = "parliamentary-questions-production"
}

variable "repo_name" {
  default = "parliamentary-questions"
}

variable "team_name" {
  default = "pq-team"
}

variable "domain" {
  default = "trackparliamentaryquestions.service.gov.uk"
}


variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}
