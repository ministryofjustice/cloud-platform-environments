variable "namespace" {
  default = "laa-cla-backend-staging"
}

variable "business_unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "Backend API for the Civil Legal Aid applications"
}

variable "repo_name" {
  default = "cla_backend"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "civil-legal-advice@digital.justice.gov.uk"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Information and Advice"
}


variable "vpc_name" {
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

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "kubernetes_cluster" {}

variable "db_identifier" {
  description = "Identifier for the restored RDS instance"
  type        = string
}

variable "db_subnet_group_name" {
  description = "RDS subnet group name"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.small"
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "source_db_instance_identifier" {
  description = "Source RDS instance to restore from"
  type        = string
  default = "laa-cla-backend-staging-pitr"
}



