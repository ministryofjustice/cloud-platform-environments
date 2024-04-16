resource "aws_route53_zone" "intranet_route53_zone" {
  name = var.base_domain

  # This will delete any attached records. Then the zone itself will be deleted.
  force_destroy = true

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
