resource "aws_route53_zone" "ccrc_route53_zone" {
  name = "ccrc.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ccrc_route53_zone_sec" {
  metadata {
    name      = "ccrc-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  }
}

resource "aws_route53_record" "ccrc_route53_a_record_sslvpn" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "sslvpn.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["4.158.26.205"]
}

resource "aws_route53_record" "ccrc_route53_a_record_connect" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "connect.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["178.239.100.157"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mail" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mail.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["79.170.44.57"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mail2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mail2.ccrc.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["20.49.250.153"]
}

resource "aws_route53_record" "ccrc_route53_a_record_mta" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mta-sts.ccrc.gov.uk"
  type    = "A"

  alias {
    name                   = "d17g7hcsgudvb4.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ccrc_route53_mx_record_outlook" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ccrc.gov.uk"
  type    = "MX"
  ttl     = "300"
  records = ["10 CCRC-gov-uk.mail.protection.outlook.com."]
}

resource "aws_route53_record" "ccrc_route53_txt_record_main" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["MS=ms13510705", "moTzn29k+pERDZNgHyOtkGiR+/ckQKBhpJDwsM558yZCe4wETnTgQswUIVDMjxIQrRQyPxznbg0qy6o17si9qQ==", "68mnpg8h53n9jr4htpl2529xm5jyvx4f", "v=spf1 a mx include:spf.protection.outlook.com include:mailgun.org include:_spf.elasticemail.com ip4:80.6.91.150 ip4:141.193.33.66 -all"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_asvdns-332ae0bd-1b7a-46fd-825b-cfcbda0c2f0c.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["asvdns_feca725b-fbca-49e0-8928-f647ef79edb0"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_asvdns2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_asvdns-8539c3d4-beae-4dfc-bf69-d83ccae823af.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_99c04153-9cca-452e-b8af-08f9ae474081"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_dmarc" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_dmarc.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DMARC1;p=quarantine;rua=mailto:PSm6GLjJ2Yt@dmarc-rua.mailcheck.service.ncsc.gov.uk;"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_mta_sts" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_mta-sts.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=STSv1; id=61658d49bbc2aee51b11cebf1d37ae83"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_smtp" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_smtp._tls.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_smtp2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_smtp._tls.imb.org.uk.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=TLSRPTv1;rua=mailto:tls-rua@mailcheck.service.ncsc.gov.uk"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_s1" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "s1._domainkey.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8+d/wBBjA8aowURIzHyUMEDn4eUfkcyfLpRP9yUlRLeeuRcT9ZoxGAnZu0iSNoct7TjDAVzwveQs9j06jfoHXtSXtLWql\"\"x//Xn624rZkUAI/8XSKZfj9ivczZR8MK7PUhiRiPe8B52dYAGIN4W+mTrergQBtNv40sx9masfhaUfsheOa+0aMp3uHz0+CDypls9WjZN6tTUDIV+VPlVX2cslNLWqNg8gy9zWNX7fNc85yRGAjtY12AYv1uBfZOabwYXDyCmEpjz/13VOHobZ0tVO9DWY4qU9YtIGICa2pEBfj1VsoI+TlPxhRFJ1kUhtsnsbh4tiEUtq1H60Q194dKwIDAQAB"]
}

resource "aws_route53_record" "ccrc_route53_txt_record_api_dk" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "api._domainkey.ccrc.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["k=rsa;t=s;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbmGbQMzYeMvxwtNQoXN0waGYaciuKx8mtMh5czguT4EZlJXuCt6V+l56mmt3t68FEX5JJ0q4ijG71BGoFRkl87uJi7LrQt1ZZ\"\"mZCvrEII0YO4mp8sDLXC8g1aUAoi8TJgxq2MJqCaMyj5kAm3Fdy2tzftPCV/lbdiJqmBnWKjtwIDAQAB"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_tracking" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "tracking.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["api.elasticemail.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwn" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwn._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwn2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwn2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwn2.domainkey.u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwo" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwo._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mwo2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "mwo2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["mwo2.domainkey.u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "selector1._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector1-ccrc-gov-uk._domainkey.ccrcuk.onmicrosoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "selector2._domainkey.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["selector2-ccrc-gov-uk._domainkey.ccrcuk.onmicrosoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "autodiscover.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_sendgrid" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "em6039.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u25846363.wl114.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_sendgrid2" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "em6531.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u26084809.wl060.sendgrid.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "enterpriseenrollment.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "enterpriseregistration.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_careers" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "careers.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["talosats-node-careerspages.azurewebsites.net"]
}

resource "aws_route53_record" "ccrc_route53_cname_record_mta_sts" {
  zone_id = aws_route53_zone.ccrc_route53_zone.zone_id
  name    = "_9e111899dbb1e73aed800dd796c849f4.mta-sts.ccrc.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_529da6734664ecca58ad43f6298844fe.bkngfjypgb.acm-validations.aws"]
}
