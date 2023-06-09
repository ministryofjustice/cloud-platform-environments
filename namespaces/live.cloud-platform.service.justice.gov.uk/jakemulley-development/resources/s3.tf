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

module "cdn" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-cloudfront?ref=initial"

  # Configuration
  enabled         = true
  is_ipv6_enabled = true

  # Origin
  origin = {
    domain_name = "https://${module.s3.bucket_name}.s3.eu-west-2.amazonaws.com" # tidy up
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