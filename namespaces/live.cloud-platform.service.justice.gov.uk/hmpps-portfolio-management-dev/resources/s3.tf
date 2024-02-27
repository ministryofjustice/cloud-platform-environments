module "s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  providers = {
    aws = aws.london
  }

  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  versioning                    = true
  enable_allow_block_pub_access = false

  bucket_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowBucketAccess",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_iam_user.s3_user.arn}"
        },
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "$${bucket_arn}",
          "$${bucket_arn}/*"
        ]
      }
    ]
  }
  EOF

}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn           = module.s3_bucket.bucket_arn
    bucket_name          = module.s3_bucket.bucket_name
    s3_access_user_arn   = aws_iam_user.s3_user.arn
    s3_access_key_id     = aws_iam_access_key.s3_user.id
    s3_secret_access_key = aws_iam_access_key.s3_user.secret
  }
}

resource "github_actions_secret" "s3_bucket" {
  repository      = "hmpps-github-teams"
  secret_name     = "TERRAFORM_S3_BUCKET_NAME"
  plaintext_value = module.s3_bucket.bucket_name
}

resource "github_actions_secret" "aws_access_key_id" {
  repository      = "hmpps-github-teams"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.s3_user.id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository      = "hmpps-github-teams"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.s3_user.secret
}

resource "github_actions_secret" "aws_region" {
  repository      = "hmpps-github-teams"
  secret_name     = "AWS_DEFAULT_REGION"
  plaintext_value = data.aws_region.current.name
}

resource "github_actions_secret" "aws_account_id" {
  repository      = "hmpps-github-teams"
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = data.aws_caller_identity.current.account_id
}
