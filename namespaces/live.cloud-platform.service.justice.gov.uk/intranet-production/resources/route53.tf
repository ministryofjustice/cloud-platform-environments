# forcing a recheck
resource "aws_route53_zone" "intranet_justice_gov_uk_zone" {
  name = "intranet.justice.gov.uk"

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

# Alias for tactical products
resource "aws_route53_record" "redirect_production" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "intranet.justice.gov.uk."
  type    = "A"

  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.intra-loadb-1vuugtgd901a4-9454459.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_production_www" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "www.intranet.justice.gov.uk."
  type    = "A"

  alias {
    zone_id                = "ZHURV8PSTC4K8"
    name                   = "dualstack.intra-loadb-1vuugtgd901a4-9454459.eu-west-2.elb.amazonaws.com."
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "intranet.justice.gov.uk."
  type    = "MX"
  ttl     = 1800
  records = [
    "0 ."
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 -all"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "_dmarc.intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"
  ]
}

resource "aws_route53_record" "domain_key" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "*._domainkey.intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DKIM1; p="
  ]
}

resource "aws_route53_record" "acm_validation" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "_ef76ae985bbcaaeab415aa727e238bd3.intranet.justice.gov.uk."
  type    = "CNAME"
  ttl     = 300
  records = [
    "_9696659a7f7af61820dfcd3d7d3b11d7.jhztdrwbnw.acm-validations.aws."
  ]
}

resource "aws_route53_record" "acm_validation_www" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "_c4588e06b18aaa08a3216ec2f416a48a.www.intranet.justice.gov.uk."
  type    = "CNAME"
  ttl     = 300
  records = [
    "_b273edbb80229cf8a6d790e16b5c1a82.jhztdrwbnw.acm-validations.aws."
  ]
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
    name_servers = join("\n", aws_route53_zone.intranet_justice_gov_uk_zone.name_servers)
  }
}
