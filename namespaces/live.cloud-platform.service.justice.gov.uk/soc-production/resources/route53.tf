resource "aws_route53_zone" "soc_route53_zone" {
  name = "hmcts-risk-assurance-operating-controls.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "soc_route53_zone_sec" {
  metadata {
    name      = "soc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.soc_route53_zone.zone_id
  }
}

resource "aws_route53_record" "add_cname_staging_entry" {
  name    = "staging.entry.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["socentrycore31postgresql-staging.eu-west-2.elasticbeanstalk.com"]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_staging_reporting" {
  name    = "staging.reporting.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["socreportingcore31postgresql-staging.eu-west-2.elasticbeanstalk.com"]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_production_entry" {
  name    = "entry.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["socentrycore31postgresql-production.eu-west-2.elasticbeanstalk.com"]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_production_reporting" {
  name    = "reporting.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["socreportingcore31postgresql-production.eu-west-2.elasticbeanstalk.com"]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_validation" {
  name    = "_e07ef66499847ab1e4670ce210948272.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["_f6dfadafe93b53a557a93f9fdb14f07b.zjfbrrwmzc.acm-validations.aws."]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_validation_entry" {
  name    = "_5b488927c92a242ccce8a3b032762aaa.entry.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["_9381b6f8f82cdf821b4ab2cc2afc18d9.bbfvkzsszw.acm-validations.aws."]
  ttl     = "300"
}

resource "aws_route53_record" "add_cname_validation_reporting" {
  name    = "_db41183928aae4d80c8532c99fca554a.reporting.hmcts-risk-assurance-operating-controls.service.justice.gov.uk"
  zone_id = aws_route53_zone.soc_route53_zone.zone_id
  type    = "CNAME"
  records = ["_04d4bcf62dc9112fc1997b6d5eba1d23.bbfvkzsszw.acm-validations.aws."]
  ttl     = "300"
}

