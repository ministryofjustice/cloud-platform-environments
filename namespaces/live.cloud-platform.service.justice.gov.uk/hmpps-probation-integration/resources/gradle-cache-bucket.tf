module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  bucket_name            = "hmpps-probation-integration-gradle-cache"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  oidc_providers         = ["github"]
  github_actions_prefix  = "GRADLE_CACHE"
  github_repositories    = ["hmpps-probation-integration-services"]
  lifecycle_rule = [
    {
      id         = "expiry"
      enabled    = true
      expiration = [{ days = 90 }]
    },
  ]
}
