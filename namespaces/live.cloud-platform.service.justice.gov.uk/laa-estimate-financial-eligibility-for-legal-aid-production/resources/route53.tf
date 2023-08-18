resource "aws_route53_zone" "eligibility_team_route53_zone" {
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

resource "kubernetes_secret" "eligibility_team_route53_zone" {
  metadata {
    name      = "eligibility-team-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.eligibility_team_route53_zone.zone_id
    nameservers = join(", ", aws_route53_zone.eligibility_team_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "eligibility_team_route53_txt_spf_record" {
  zone_id = aws_route53_zone.eligibility_team_route53_zone.zone_id
  name    = "https://check-your-client-qualifies-for-legal-aid.service.gov.uk"
  type    = "TXT"
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "eligibility_team_route53_txt_dmarc_record" {
  zone_id = aws_route53_zone.eligibility_team_route53_zone.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; fo=1; rua=mailto:dmarc-rua@dmarc.service.gov.uk,mailto:eligibility@justice.gov.uk"]
}

resource "aws_route53_record" "eligibility_team_route53_txt_dkim_record" {
  zone_id = "aws_route53_zone.eligibility_team_route53_zone.zone_id"
  name    = "*._domainkey"
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; p="]
}

resource "aws_route53_record" "eligibility_team_route53_mx_record" {
  zone_id  = aws_route53_zone.eligibility_team_route53_zone.zone_id
  type     = "MX"
  priority = 0
  value    = "."
}
