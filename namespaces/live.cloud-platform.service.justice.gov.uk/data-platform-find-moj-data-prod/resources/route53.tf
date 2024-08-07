resource "aws_route53_zone" "find_moj_data_prod_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "find_moj_data_prod_route53_zone_sec" {
  metadata {
    name      = "find-moj-data-prod-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.find_moj_data_prod_zone.zone_id
    nameservers = join("\n", aws_route53_zone.find_moj_data_prod_zone.name_servers)
  }
}

resource "aws_route53_record" "user_guide" {
  name    = "user-guide.find-moj-data.service.justice.gov.uk"
  zone_id = aws_route53_zone.find_moj_data_prod_zone.zone_id
  type    = "CNAME"
  records = ["ministryofjustice.github.io/find-moj-data-user-guide/"]
  ttl     = "300"
}

resource "aws_route53_record" "runbooks" {
  name    = "runbooks.find-moj-data.service.justice.gov.uk"
  zone_id = aws_route53_zone.find_moj_data_prod_zone.zone_id
  type    = "CNAME"
  records = ["ministryofjustice.github.io/find-moj-data-runbooks/"]
  ttl     = "300"
}
