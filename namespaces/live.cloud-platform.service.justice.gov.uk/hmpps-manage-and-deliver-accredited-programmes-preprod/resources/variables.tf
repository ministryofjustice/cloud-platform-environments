variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "Accredited Programmes Manage And Deliver"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "hmpps-manage-and-deliver-accredited-programmes-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "Platforms"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "hmpps-accredited-programmes-manage-and-deliver-devs"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "preprod"
}

variable "environment-name" {
  default = "preprod"
}


variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "interventions-devs@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "hmpps_accredited_programmes_manage_and_deliver"
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

variable "number_cache_clusters" {
  default = "2"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
  default     = 200
}

variable "db_engine" {
  description = "The DB engine to use for the RDS instance"
  type        = string
  default     = "sqlserver-web"
}

variable "db_engine_version" {
  description = "The DB engine version for the RDS instance"
  type        = string
  default     = "15.00.4345.5.v1"
}

variable "db_instance_class" {
  description = "The DB instance class for the RDS instance"
  type        = string
  default     = "db.m5.large"
}

variable "db_name" {
  description = "The name of the DB"
  type        = string
  default     = "hmpps-manage-and-deliver-acp-preprod-mssql"
}

variable "db_rds_family" {
  description = "The RDS family for the RDS instance"
  type        = string
  default     = "sqlserver-web-15.0"
}

variable "db_storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable "character_set_name" {
  description = "The character set name for the RDS instance. Cannot be set with the snapshot identifier. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance"
  type        = string
  default     = null
}

variable "force_ssl_apply_method" {
  description = "The apply method for force SSL"
  type        = string
  default     = "pending-reboot"
}

variable "force_ssl_value" {
  description = "The value to set for forcing SSL"
  type        = number
  default     = 1
}

variable "sqlserver_restore_create_snapshot" {
  description = "Boolean to declare whether or not a snapshot should be taken before the sqlserver restore"
  type        = bool
  default     = true
}
