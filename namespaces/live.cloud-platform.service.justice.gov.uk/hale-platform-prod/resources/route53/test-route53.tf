resource "aws_route53_record" "test_route53_txt_record" {
  zone_id = aws_route53_zone.victimscode_route53_zone.zone_id
  name    = "victimscode.org.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["test"]
}