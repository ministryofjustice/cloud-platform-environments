module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"

  # Tags
  application            = var.application
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
