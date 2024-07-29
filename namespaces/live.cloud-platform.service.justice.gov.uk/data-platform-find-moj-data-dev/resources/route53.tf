resource "aws_route53_zone" "find_moj_data_dev_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "find_moj_data_dev_zone_secret" {
  metadata {
    name      = "find-moj-data-dev-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.find_moj_data_dev_zone.zone_id
    nameservers = join("\n", aws_route53_zone.find_moj_data_dev_zone.name_servers)
  }
}

# Short-lived credentials (IRSA)
data "aws_iam_policy_document" "find_moj_data_dev_zone_irsa" {
  version = "2012-10-17"

  statement {
    sid    = "AllowRoute53ViewAccessForFindMojDataDev"
    effect = "Allow"
    actions = [
      "route53:Get*",
      "route53:List*",
      "route53:TestDNSAnswer"
    ]

    resources = [
      aws_route53_zone.find_moj_data_dev_zone.arn
    ]
  }
}

resource "aws_iam_policy" "route53_irsa" {
  name   = "find-moj-data-${var.environment}-route53-irsa"
  policy = data.aws_iam_policy_document.find_moj_data_dev_zone_irsa.json
  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}
