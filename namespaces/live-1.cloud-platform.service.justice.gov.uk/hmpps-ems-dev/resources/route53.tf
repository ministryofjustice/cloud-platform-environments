resource "aws_route53_zone" "route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

# # Acquisitive Crime Development
# resource "aws_route53_record" "hmpps_ems_ac_dev_zone" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "ac.dev.${var.domain}"
#   type    = "NS"
#   ttl     = "600"
#   records = ["TBC", "TBC", "TBC", "TBC"]
# }

# Acquisitive Crime Test
resource "aws_route53_record" "hmpps_ems_ac_test_zone" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "ac.test.${var.domain}"
  type    = "NS"
  ttl     = "600"
  records = ["ns-1390.awsdns-45.org.", "ns-99.awsdns-12.com.", "ns-535.awsdns-02.net.", "ns-1979.awsdns-55.co.uk"]
}

# # Acquisitive Crime PreProd
# resource "aws_route53_record" "hmpps_ems_ac_preprod_zone" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "ac.preprod.${var.domain}"
#   type    = "NS"
#   ttl     = "600"
#   records = ["TBC", "TBC", "TBC", "TBC"]
# }
