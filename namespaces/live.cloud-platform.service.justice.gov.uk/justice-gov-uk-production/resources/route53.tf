resource "aws_route53_zone" "www_justice_gov_uk_route53_zone" {
  name = "www.justice.gov.uk"

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

resource "aws_route53_record" "squiz_a_record" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "www.justice.gov.uk."
  type    = "A"
  ttl     = 300
  records = [
    "185.64.253.120"
  ]
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "www.justice.gov.uk."
  type    = "MX"
  ttl     = 1800
  records = [
    "0 ."
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 -all"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "_dmarc.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"
  ]
}

resource "aws_route53_record" "domain_key" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "*._domainkey.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DKIM1; p="
  ]
}

resource "aws_route53_record" "github_challenge_moj" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "_github-challenge-ministryofjustice.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "80b1cb80e6"
  ]
}

resource "aws_route53_record" "github_challenge_moj_as" {
  zone_id = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
  name    = "_github-challenge-moj-analytical-services.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "a75165038c"
  ]
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.www_justice_gov_uk_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.www_justice_gov_uk_route53_zone.name_servers)
  }
}
