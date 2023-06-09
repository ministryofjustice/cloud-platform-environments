module "s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=jakemulley-patch-1"

  # Tags
  application            = var.application
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

module "cdn" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=initial"

  # Configuration
  enabled         = true
  is_ipv6_enabled = true

  # Origin
  origin = {
    domain_name = module.s3.bucket_domain_name
  }

  # Tags
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}
