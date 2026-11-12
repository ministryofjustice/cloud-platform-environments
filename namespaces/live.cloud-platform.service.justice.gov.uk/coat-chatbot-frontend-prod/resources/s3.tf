module "coat_chatbot_auth0_tf_state_prod_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  oidc_providers = ["github"]
  github_repositories = ["coat-chatbot-frontend-v2"]
  github_actions_prefix = "PROD"

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-coat-chatbot-auth0-tf-state-prod"
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

resource "kubernetes_secret" "coat_chatbot_auth0_tf_state_prod_s3_bucket" {
  metadata {
    name      = "coat-chatbot-auth0-tf-state-prod-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coat_chatbot_auth0_tf_state_prod_s3_bucket.bucket_arn
    bucket_name = module.coat_chatbot_auth0_tf_state_prod_s3_bucket.bucket_name
  }
}