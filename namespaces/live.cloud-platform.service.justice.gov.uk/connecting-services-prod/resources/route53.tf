resource "aws_route53_zone" "pfl_cs_route53_zone" {
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

resource "kubernetes_secret" "pfl_cs_route53_zone_sec" {
  metadata {
    name      = "pfl-cs-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.pfl_cs_route53_zone.name_servers)
  }
}


# Microsoft Entra/Outlook related
resource "aws_route53_record" "pfl_cs_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "pfl_cs_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "3600"
  records = ["0 findchildarrangementoption-service-gov-uk01be2e.mail.protection.outlook.com"]
}

resource "aws_route53_record" "entra_id_verification" {
  zone_id = aws_route53_zone.pfl_cs_route53_zone.zone_id
  name    = var.domain
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms72370887", "v=spf1 include:spf.protection.outlook.com -all"]
}
