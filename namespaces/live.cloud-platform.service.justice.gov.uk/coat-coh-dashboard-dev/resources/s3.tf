module "coat_coh_dashboard_auth0_tf_state_dev_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  oidc_providers = ["github"]
  github_repositories = ["coat-coh-dashboard"]
  github_actions_prefix = "DEV"

  versioning = true
  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-3rd-noncurrent-version"
      abort_incomplete_multipart_upload_days = 90
      noncurrent_version_expiration = [
        {
          days = 30
          newer_noncurrent_versions = 2
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "coat_coh_dashboard_auth0_tf_state_dev_s3_bucket" {
  metadata {
    name      = "coat-coh-dashboard-auth0-tf-state-dev-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.coat_coh_dashboard_auth0_tf_state_dev_s3_bucket.bucket_arn
    bucket_name = module.coat_coh_dashboard_auth0_tf_state_dev_s3_bucket.bucket_name
  }
}