module "coat_chatbot_auth0_tf_state_dev_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=fix-s3-oidc-immutable-subject-claims"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "COATMPDevAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::082282578003:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_modernisation-platform-sandbox_befb4340ef5f2771"
      },
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "$${bucket_arn}",
        "$${bucket_arn}/*"
      ]
    }
  ]
}
EOF

  oidc_providers = ["github"]
  github_repositories = ["coat-chatbot-frontend-v2"]
  github_actions_prefix = "DEV"

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-coat-chatbot-auth0-tf-state-dev"
      abort_incomplete_multipart_upload_days = 90
      expiration = [
        {
          days = 30
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "coat_chatbot_auth0_tf_state_dev_s3_bucket" {
  metadata {
    name      = "coat-chatbot-auth0-tf-state-dev-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coat_chatbot_auth0_tf_state_dev_s3_bucket.bucket_arn
    bucket_name = module.coat_chatbot_auth0_tf_state_dev_s3_bucket.bucket_name
  }
}