resource "aws_route53_record" "gold_scorecard_form_app" {
  zone_id = aws_route53_zone.data_platform_apps_alpha_route53_zone.id
  name    = "gold-scorecard-form"
  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.dns_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gold_scorecard_form_test" {
  zone_id = aws_route53_zone.data_platform_test_alpha_route53_zone.id
  name    = "gold-scorecard-form"
  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.dns_zone_id
    evaluate_target_health = true
  }
}
