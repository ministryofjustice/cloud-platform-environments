# auto-generated from fb-cloud-platforms-environments
##################################################
# User Filestore S3
module "user-filestore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=3.3"

  team_name              = "${var.team_name}"
  acl                    = "private"
  versioning             = false
  business-unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is-production          = "${var.is-production}"
  environment-name       = "${var.environment-name}"
  infrastructure-support = "${var.infrastructure-support}"

  providers = {
    aws = "aws.london"
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
      "s3:ListBucketVersions",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration"
    ],
    "Resource": "$${bucket_arn}"
  },
  {
    "Sid": "",
    "Effect": "Allow",
    "Action": [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
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

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-28d"
      prefix                                 = "28d/"
      abort_incomplete_multipart_upload_days = 28

      expiration = [
        {
          days = 28
        },
      ]

      noncurrent_version_expiration = [
        {
          days = 28
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "user-filestore-s3-bucket" {
  metadata {
    name      = "s3-formbuilder-user-filestore-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data {
    access_key_id     = "${module.user-filestore-s3-bucket.access_key_id}"
    bucket_arn        = "${module.user-filestore-s3-bucket.bucket_arn}"
    bucket_name       = "${module.user-filestore-s3-bucket.bucket_name}"
    secret_access_key = "${module.user-filestore-s3-bucket.secret_access_key}"
  }
}
