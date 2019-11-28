variable "environment-name" {
  default = "live-production"
}

variable "team_name" {
  default = "cloud-platform"
}

variable "application" {
  default = "jason-lab-test"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "platforms@digital.justice.gov.uk"
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console."
  default     = ""
}

variable "db_allocated_storage" {
  description = "The allocated storage in gibibytes"
  default     = "10"
}

variable "db_engine" {
  description = "Database engine used e.g. postgres, mqsql"
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The engine version to use e.g. 10"
  default     = "10"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.small"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups. Must be 1 or greater to be a source for a Read Replica"
  default     = "7"
}

variable "db_iops" {
  description = "The amount of provisioned IOPS. Setting this to a value other than 0 implies a storage_type of io1"
  default     = "0"
}

variable "db_name" {
  description = "The name of the database to be created on the instance (if empty, it will be the generated random identifier)"
  default     = ""
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  default     = "false"
}

variable "force_ssl" {
  description = "Enforce SSL connections, set to true to enable"
  default     = "false"
}

variable "rds_family" {
  description = "Maps the postgres version with the rds family, a family often covers several versions"
  default     = "postgres10"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

