resource "aws_route53_zone" "route53_zone_laa_record_link_service_prd" {
  name = "laa-ccms-user-data-transfer.service.justice.gov.uk"

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

resource "kubernetes_secret" "route53_zone_secret_laa_record_link_service_prd" {
  metadata {
    name      = "laa-record-link-service-route53-secret-prd"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.route53_zone_laa_record_link_service_prd.zone_id
    nameservers = join("\n", aws_route53_zone.route53_zone_laa_record_link_service_prd.name_servers)
  }
}