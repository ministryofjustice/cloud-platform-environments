

variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "MoJ Frontend guidance site"
}

variable "namespace" {
  default = "moj-frontend"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "mojds-maintainers"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "moj-pattern-library-support"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

## Prototype kit variables

variable "basic-auth-username" {
  description = "Basic auth. username of the deployed prototype website"
  default     = "preview"
}

variable "basic-auth-password" {
  description = "Basic auth. password of the deployed prototype website"
  default     = "patterns"
}

variable "domain" {
  default = "design-patterns.service.justice.gov.uk"
  type    = string
}
