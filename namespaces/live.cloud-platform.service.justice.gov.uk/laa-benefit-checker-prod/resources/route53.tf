resource "aws_route53_zone" "laa_benefit_checker_prod_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "laa_benefit_checker_prod_route53_zone_sec" {
  metadata {
    name      = "laa-benefit-checker-prod-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.laa_benefit_checker_prod_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.laa_benefit_checker_prod_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "bc_prod" {
  name    = "_dnsauth.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_benefit_checker_prod_route53_zone.zone_id
  type    = "TXT"
  records = ["_tyttd3pyud91whfny2se5drtdrzpjqx"]
  ttl     = "300"
}

resource "aws_route53_record" "bc_uat" {
  name    = "_dnsauth.uat.laa-benefit-checker.service.justice.gov.uk"
  zone_id = aws_route53_zone.laa_benefit_checker_prod_route53_zone.zone_id
  type    = "TXT"
  records = ["_k4qv2zs12d60tjemvcgi6qajvsxwewz"]
  ttl     = "300"
}
