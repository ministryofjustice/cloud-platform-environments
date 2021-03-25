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

# # Acquisitive Crime Test
# resource "aws_route53_record" "hmpps_ems_ac_dev_zone" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "ac.test.${var.domain}"
#   type    = "NS"
#   ttl     = "600"
#   records = ["TBC", "TBC", "TBC", "TBC"]
# }

# # Acquisitive Crime PreProd
# resource "aws_route53_record" "hmpps_ems_ac_dev_zone" {
#   zone_id = aws_route53_zone.route53_zone.zone_id
#   name    = "ac.preprod.${var.domain}"
#   type    = "NS"
#   ttl     = "600"
#   records = ["TBC", "TBC", "TBC", "TBC"]
# }