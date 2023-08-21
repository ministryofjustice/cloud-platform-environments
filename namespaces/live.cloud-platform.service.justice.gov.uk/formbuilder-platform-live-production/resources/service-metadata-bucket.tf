module "service-metadata-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = "transformed-department"
  application            = "formbuilderservicemetadata"
  is-production          = var.is_production
  environment-name       = var.environment-name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

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
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions"
    ],
    "Resource": "$${bucket_arn}"
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject"
    ],
    "Resource": "$${bucket_arn}/*"
  }
]
}
EOF
}

resource "kubernetes_secret" "service-metadata-s3-bucket" {
  metadata {
    name      = "s3-service-metadata-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    access_key_id     = module.service-metadata-s3-bucket.access_key_id
    bucket_arn        = module.service-metadata-s3-bucket.bucket_arn
    bucket_name       = module.service-metadata-s3-bucket.bucket_name
    secret_access_key = module.service-metadata-s3-bucket.secret_access_key
  }
}
