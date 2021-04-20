variable "namespace" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation-prod"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "prod"
}

variable "is-production" {
  default = "true"
}

variable "domain" {
  default = "claim-criminal-injuries-compensation.service.justice.gov.uk"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email"
  default     = "Infrastructure@cica.gov.uk"
}

variable "db_backup_retention_period" {
  description = "The days to retain backup jobs. Must be 1 or greater to be a source for a Read Replica"
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

# For Push gateway
variable "service_monitor" {
  description = "If true, prometheus will automatically scrape"
  default     = true
}
