
resource "aws_route53_zone" "parliamentary_questions" {
  name = var.domain

  tags = {
    business-unit          = var.team_name
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "parliamentary_questions_route53" {
  metadata {
    name      = "parliamentary-questions-route53"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.parliamentary_questions.zone_id
    name_servers = join("\n", aws_route53_zone.parliamentary_questions.name_servers)
  }
}

resource "aws_route53_record" "pq_route53_cname0_record" {
  zone_id = aws_route53_zone.parliamentary_questions.zone_id
  name    = "_c282d3c53501f377a7c87b02b1f5e30a."
  type    = "CNAME"
  ttl     = "300"
  records = ["0E5EAFF1A065B0971AC304F6FA5D36D8.8B8E82AD41E05EE9A7DFDCEBFFA99B8C.comodoca.com."]
}

resource "aws_route53_record" "pq_route53_cname1_record" {
  zone_id = aws_route53_zone.parliamentary_questions.zone_id
  name    = "_c282d3c53501f377a7c87b02b1f5e30a.assets."
  type    = "CNAME"
  ttl     = "300"
  records = ["0E5EAFF1A065B0971AC304F6FA5D36D8.8B8E82AD41E05EE9A7DFDCEBFFA99B8C.comodoca.com."]
}

resource "aws_route53_record" "pq_route53_dmarc_record" {
  zone_id = aws_route53_zone.parliamentary_questions.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=none; rua=mailto:yl0zvgmk@ag.dmarcian.com; ruf=mailto:yl0zvgmk@fr.dmarcian.com;"]
}

resource "aws_route53_record" "pq_route53_mx_record" {
  zone_id = aws_route53_zone.parliamentary_questions.zone_id
  name    = "."
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}
