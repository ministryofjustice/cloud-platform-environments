resource "aws_route53_zone" "cats_train" {
  name = "preprod.manage-external-funded-offender-provision.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "cats_train_route53_zone" {
  metadata {
    name      = "cats-train-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.cats_train.zone_id
    nameservers = join("\n", aws_route53_zone.cats_train.name_servers)
  }
}
