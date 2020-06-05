module "cla_backend_private_reports_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.1"
  acl    = "private"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ],
    "Resource": [
      "$${bucket_arn}",
      "arn:aws:s3:::cloud-platform-3cb9c51daea32a805bae8367968d0543",
      "arn:aws:s3:::cloud-platform-fdc5e4b70a599d8ea84b4ffd31a832b3"
    ]
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:*"
    ],
    "Resource": [
      "$${bucket_arn}/*",
      "arn:aws:s3:::cloud-platform-3cb9c51daea32a805bae8367968d0543/*",
      "arn:aws:s3:::cloud-platform-fdc5e4b70a599d8ea84b4ffd31a832b3/*"
    ]
  }
]
}
EOF

}

module "cla_backend_deleted_objects_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.1"
  acl    = "private"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }

  user_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ],
    "Resource": [
      "$${bucket_arn}"
    ]
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:*"
    ],
    "Resource": [
      "$${bucket_arn}/*"
    ]
  }
]
}
EOF

}


module "cla_backend_static_files_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.1"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  is-production          = var.is-production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure-support

  providers = {
    aws = aws.london
  }

}


resource "kubernetes_secret" "cla_backend_private_reports_bucket" {
  metadata {
    name      = "s3"
    namespace = var.namespace
  }

  data = {
    access_key_id               = module.cla_backend_private_reports_bucket.access_key_id
    secret_access_key           = module.cla_backend_private_reports_bucket.secret_access_key
    reports_bucket_arn          = module.cla_backend_private_reports_bucket.bucket_arn
    reports_bucket_name         = module.cla_backend_private_reports_bucket.bucket_name
    deleted_objects_bucket_arn  = module.cla_backend_deleted_objects_bucket.bucket_arn
    deleted_objects_bucket_name = module.cla_backend_deleted_objects_bucket.bucket_name
    static_files_bucket_name    = module.cla_backend_static_files_bucket.bucket_name
    static_files_bucket_arn     = module.cla_backend_static_files_bucket.bucket_arn
  }
}
