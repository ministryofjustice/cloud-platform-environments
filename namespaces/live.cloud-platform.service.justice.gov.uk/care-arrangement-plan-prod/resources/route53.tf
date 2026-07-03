resource "aws_route53_zone" "cap_route53_zone" {
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

resource "kubernetes_secret" "cap_route53_zone_sec" {
  metadata {
    name      = "cap-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.cap_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.cap_route53_zone.name_servers)
  }
}

resource "aws_route53_zone" "pcap_zone" {
  name = "propose-child-arrangements-plan.service.gov.uk"

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

resource "kubernetes_secret" "pcap_zone_sec" {
  metadata {
    name      = "pcap-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.pcap_zone.zone_id
    nameservers = join("\n", aws_route53_zone.pcap_zone.name_servers)
  }
}

# Microsoft Entra/Outlook related
resource "aws_route53_record" "pcap_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "autodiscover"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "pcap_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "propose-child-arrangements-plan.service.gov.uk"
  type    = "MX"
  ttl     = "3600"
  records = ["0 proposechildarrangementsplan-service-gov-uk01i1c2e.mail.protection.outlook.com"]
}

resource "aws_route53_record" "entra_id_verification" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "propose-child-arrangements-plan.service.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms47915806", "v=spf1 include:spf.protection.outlook.com -all"]
}

# TXT based DKIM records
resource "aws_route53_record" "entra_id_verification_dkim1" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "selector1._domainkey.propose-child-arrangements-plan.service.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["selector1-proposechildarrangementsplan-service-gov-uk01i1c2e._domainkey.JusticeUK.n-v1.dkim.mail.microsoft"]
}

resource "aws_route53_record" "entra_id_verification_dkim2" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "selector2._domainkey.propose-child-arrangements-plan.service.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["selector2-proposechildarrangementsplan-service-gov-uk01i1c2e._domainkey.JusticeUK.n-v1.dkim.mail.microsoft"]
}

# CNAME based DKIM records
resource "aws_route53_record" "entra_id_verification_dkim1_cname" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "selector1._domainkey"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector1-proposechildarrangementsplan-service-gov-uk01i1c2e._domainkey.JusticeUK.n-v1.dkim.mail.microsoft"]
}

resource "aws_route53_record" "entra_id_verification_dkim2_cname" {
  zone_id = aws_route53_zone.pcap_zone.zone_id
  name    = "selector2._domainkey"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector2-proposechildarrangementsplan-service-gov-uk01i1c2e._domainkey.JusticeUK.n-v1.dkim.mail.microsoft"]
}
