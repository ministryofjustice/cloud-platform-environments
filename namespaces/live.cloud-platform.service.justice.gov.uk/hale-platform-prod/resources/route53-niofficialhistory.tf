resource "aws_route53_zone" "niofficialhistory_route53_zone" {
  name = "niofficialhistory.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "niofficialhistory_route53_zone_sec" {
  metadata {
    name      = "niofficialhistory-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.niofficialhistory_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "niofficialhistory_route53_cname_record_google" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "cnqopo3wv3ip.niofficialhistory.org.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["gv-twbi4p5vtx43zw.dv.googlehosted.com"]
}

resource "aws_route53_record" "niofficialhistory_route53_txt_record_main" {
  zone_id = aws_route53_zone.niofficialhistory_route53_zone.zone_id
  name    = "niofficialhistory.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=qgUm8Z7PTfhp2VkwYKKlo6-GFomNQu2QmgiU-aZ5ADo"]
}
