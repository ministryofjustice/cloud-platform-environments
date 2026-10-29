# Add outputs that need to be consumed in other namespaces here.

locals { 
  sns_publish_irsa_policy_arn = aws_iam_policy.sns_topic_irsa_publish.arn
  sns_irsa_policies = {
    (module.returns_events_sns_topic.topic_name) = local.sns_publish_irsa_policy_arn
  }
}

data "aws_iam_policy_document" "sns_topic_irsa_publish" {
  version = "2012-10-17"

  statement {
    sid    = "AllowPublishToReturnEventTopic"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]
    resources = [module.returns_events_sns_topic.topic_arn]
  }
}


resource "aws_iam_policy" "sns_topic_irsa_publish" {
  name   = "${var.namespace}-publish-hmpps-domain-events-topic"
  path   = "/cloud-platform/sns/"
  policy = data.aws_iam_policy_document.sns_topic_irsa_publish.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
    }
  }



resource "aws_ssm_parameter" "tf-outputs-sns-irsa-policies" {
  for_each = local.sns_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sns/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     ={
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}
