################################################################################
# PeopleFinder
# Route53 domain zone settings
#################################################################################

resource "aws_route53_zone" "peoplefinder_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = "Central Digital"
    application            = "peoplefinder"
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = "peoplefinder"
    infrastructure-support = "people-finder-support@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "peoplefinder_route53_zone_sec" {
  metadata {
    name      = "peoplefinder-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.peoplefinder_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.peoplefinder_route53_zone.name_servers)
  }
}

# Production alias to the template deploy loadbalancer
resource "aws_route53_record" "peoplefinder_route53_A_record_production" {
  name    = "."
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  type    = "A"

  alias {
    name    = "dualstack.peoplefind-elbprod-cymganexsxxq-1650047565.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = true
  }
}

# Sendgrid records copied from template deploy - to keep until switch to Notify
resource "aws_route53_record" "peoplefinder_route53_sendgrid_1495674" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "1495674.peoplefinder.service.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["sendgrid.net"]
}

resource "aws_route53_record" "peoplefinder_route53_sendgrid_s1" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "s1._domainkey.peoplefinder.service.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["s1.domainkey.u1495674.wl.sendgrid.net"]
}

resource "aws_route53_record" "peoplefinder_route53_sendgrid_s2" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "s2._domainkey.peoplefinder.service.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["s2.domainkey.u1495674.wl.sendgrid.net"]
}

resource "aws_route53_record" "peoplefinder_route53_sendgrid_email" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "email.peoplefinder.service.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["sendgrid.net"]
}

resource "aws_route53_record" "peoplefinder_route53_sendgrid_mail" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "mail.peoplefinder.service.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["u1495674.wl.sendgrid.net"]
}

resource "aws_route53_record" "peoplefinder_route53_sendgrid_dmarc" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "_dmarc.peoplefinder.service.gov.uk."
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=none; rua=mailto:yl0zvgmk@ag.dmarcian.com; ruf=mailto:yl0zvgmk@fr.dmarcian.com;"]
}

# Other records copied from template deploy - Do we need this one? Get rid?
resource "aws_route53_record" "peoplefinder_route53_mx" {
  zone_id = aws_route53_zone.peoplefinder_route53_zone.zone_id
  name    = "peoplefinder.service.gov.uk."
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}
