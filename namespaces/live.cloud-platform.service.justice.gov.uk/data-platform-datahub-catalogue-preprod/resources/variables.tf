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
  default     = "Datahub Catalogue"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "data-platform-datahub-catalogue-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HQ"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "data-catalogue"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = ""
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "data-catalogue"
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
}

variable "enable_rds_auto_start_stop" {
  description = "Whether to enable RDS auto start/stop"
  type        = bool
  default     = false
}

variable "backup_window" {
  type = string
  default = "22:00-23:59"
}

variable "maintenance_window" {
  default = "Sun:12:00-Sun:21:00"
}

variable "db_max_allocated_storage" {
  description = "The maximum allocated storage for the RDS instance"
  type        = string
  default     = "100"
}
variable "db_allocated_storage" {
  description = "The allocated storage for the RDS instance"
  type        = number
  default     = 20
}

variable storage_type {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable allow_minor_version_upgrade {
  description = "Whether to allow minor version upgrades for the RDS instance"
  type        = bool
  default     = true
}
variable allow_major_version_upgrade {
  description = "Whether to allow major version upgrades for the RDS instance"
  type        = bool
  default     = false
}
variable prepare_for_major_upgrade {
  description = "Whether to prepare for major upgrades for the RDS instance"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Whether to enable performance insights for the RDS instance"
  type        = bool
  default     = false
  
}
variable db_engine {
  description = "The database engine to use for the RDS instance"
  type        = string
  default     = "postgres"
}

variable db_engine_version {
  description = "The database engine version to use for the RDS instance"
  type        = string
  default     = "17.7"
}
variable rds_family {
  description = "The RDS family to use for the RDS instance"
  type        = string
  default     = "postgres17"
}
variable db_instance_class {
  description = "The instance class to use for the RDS instance"
  type        = string
  default     = "db.t4g.small"
}

variable db_parameter {
  type = list(object(
      {
        apply_method = string
        name        = string
        value       = string
      }
  ))
  default = [
    {
      apply_method = "immediate"
      name = "rds.log_retention_period"
      value = "10080"
    }
  ]
}

variable "opensearch_engine_version" {
  description = "The OpenSearch engine version to use"
  type        = string
  default     = "OpenSearch_2.19"
}

variable "opensearch_instance_type" {
  description = "The instance type to use for the OpenSearch cluster"
  type        = string
  default     = "t3.medium.search"
}

variable "opensearch_instance_count" {
  description = "The number of instances to use for the OpenSearch cluster"
  type        = number
  default     = 3
}

variable "opensearch_ebs_volume_size" {
  description = "The EBS volume size to use for the OpenSearch cluster"
  type        = number
  default     = 50
  
}