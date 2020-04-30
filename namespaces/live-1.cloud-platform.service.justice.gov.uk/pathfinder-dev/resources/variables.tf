variable "application" {
  default = "pathfinder"
}

variable "namespace" {
  default = "pathfinder-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services/New Nomis"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "document_bucket_user_policy" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration"
      ],
      "Resource": "$${bucket_arn}"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": "$${bucket_arn}/*"
    }
  ]
}
EOF

