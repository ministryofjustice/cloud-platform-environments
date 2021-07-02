module "hmpps-workload-dev-s3-bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.6"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  namespace              = var.namespace
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  versioning = true

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "retire extracts after 30 days"
      prefix  = "extract/"
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
      expiration = [
        {
          days = 30
        },
      ]
    }
  ]


  bucket_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3PutPolicy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::050243167760:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "$${bucket_arn}/*",
                "$${bucket_arn}"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
             "Sid": "S3ListPolicy",
             "Effect": "Allow",
             "Principal": {
                 "AWS": "arn:aws:iam::050243167760:root"
             },
             "Action": [
                  "s3:List*",
                  "s3:DeleteObject*",
                  "s3:GetObject*",
                  "s3:GetBucketLocation"
             ],
             "Resource": [
                  "$${bucket_arn}/*",
                  "$${bucket_arn}"
             ]
        }
    ]
}
EOF


}

resource "kubernetes_secret" "hmpps-workload-dev-s3-bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps-workload-dev-s3-bucket.access_key_id
    secret_access_key = module.hmpps-workload-dev-s3-bucket.secret_access_key
    bucket_arn        = module.hmpps-workload-dev-s3-bucket.bucket_arn
    bucket_name       = module.hmpps-workload-dev-s3-bucket.bucket_name
  }
}
