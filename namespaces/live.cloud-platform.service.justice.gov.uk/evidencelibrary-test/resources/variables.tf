

variable "vpc_name" {
}
variable "kubernetes_cluster" {
}
variable "eks_cluster_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Published evidence for both internal and external public viewing"
}

variable "namespace" {
  default = "evidencelibrary-test"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "evidencelibrary"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "test"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hubusers@justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "evidence-library"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "rds-family" {
  default = "postgres13"
}

variable "db_engine_version" {
  default = "13"
}

variable "db_instance_class" {
  default = "db.t3.small"
}
