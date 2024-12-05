module "hmpps-person-record-ndelius-s3-extract" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  versioning = false

  providers = {
    aws = aws.london
  }


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
                 "AWS": ["arn:aws:iam::050243167760:root",
                 "arn:aws:iam::754256621582:role/cloud-platform-irsa-328cabd0a133b6ac-live"]
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

resource "kubernetes_secret" "hmpps-person-record-ndelius-s3-extract-secret" {
  metadata {
    name      = "ndelius-s3-extract-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-person-record-ndelius-s3-extract.bucket_arn
    bucket_name = module.hmpps-person-record-ndelius-s3-extract.bucket_name
  }
}
