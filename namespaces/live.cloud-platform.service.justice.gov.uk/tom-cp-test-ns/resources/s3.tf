module "s3_test_oidc" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=fix-s3-oidc-immutable-subject-claims"

  # S3 configuration
  versioning = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  oidc_providers      = ["github"]
  github_repositories = ["cloud-platform-test-application"]

}
