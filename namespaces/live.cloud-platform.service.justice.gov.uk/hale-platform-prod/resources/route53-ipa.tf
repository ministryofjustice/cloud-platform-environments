resource "aws_route53_zone" "ipa_route53_zone" {
  name = "independentpublicadvocate.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ipa_route53_zone_sec" {
  metadata {
    name      = "ipa-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ipa_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.ipa_route53_zone.name_servers)
  }
}
resource "aws_route53_record" "ipa_route53_txt_record_main" {
  zone_id = aws_route53_zone.ipa_route53_zone.zone_id
  name    = "independentpublicadvocate.org.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms14912346", "v=spf1 include:spf.protection.outlook.com -all"]
}

resource "aws_route53_record" "ipa_route53_mx_record" {
  zone_id = aws_route53_zone.ipa_route53_zone.zone_id
  name    = "independentpublicadvocate.org.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 independentpublicadvocate-org-uk.mail.protection.outlook.com."]
}

resource "aws_route53_record" "ipa_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.ipa_route53_zone.zone_id
  name    = "autodiscover.independentpublicadvocate.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com."]
}


