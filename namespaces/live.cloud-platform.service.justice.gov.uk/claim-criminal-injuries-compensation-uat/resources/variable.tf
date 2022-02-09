variable "namespace" {
  default = "claim-criminal-injuries-compensation-uat"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-uat"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "uat"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backups. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

variable "acl" {
  description = "The bucket ACL to set"
  default     = "private"
}

variable "bucket_policy" {
  description = "The S3 bucket policy to set. If empty, no policy will be set"
  default     = ""
}

variable "user_policy" {
  description = "The IAM policy to assign to the generated user. If empty, the default policy is used"
  default     = ""
}

variable "versioning" {
  description = "Enable object versioning for the bucket"
  default     = false
}

variable "lifecycle_rule" {
  description = "lifecycle"
  default     = []
}

variable "cors_rule" {
  description = "cors rule"
  default     = []
}
