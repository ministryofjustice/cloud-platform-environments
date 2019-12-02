
resource "aws_route53_zone" "peoplefinder_route53_zone" {
  name = var.domain
  tags = {
    business-unit          = var.team_name
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}