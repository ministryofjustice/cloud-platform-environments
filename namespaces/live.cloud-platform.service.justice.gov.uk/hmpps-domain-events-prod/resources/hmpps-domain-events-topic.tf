module "hmpps-domain-events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "hmpps-domain-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_ssm_parameter" "param-store-topic-arn" {
  type        = "String"
  name        = "/${var.namespace}/topic-arn"
  value       = module.hmpps-domain-events.topic_arn
  description = "SNS topic ARN for ${var.namespace}; use this parameter from other DPS production namespaces"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

data "aws_caller_identity" "cloud_platform" {}
data "kubernetes_secret" "modernisation_platform" {
  metadata {
    name      = "modernisation-platform"
    namespace = var.namespace
  }
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    sid     = "__default_statement_ID"
    effect  = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.hmpps-domain-events.topic_arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.cloud_platform.account_id]
    }
  }
  statement {
    sid    = "CrossAccountOASysReadAccess"
    effect = "Allow"
    actions = [
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:Subscribe",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.kubernetes_secret.modernisation_platform.data.oasys_account_id}:root"]
    }
    resources = [module.hmpps-domain-events.topic_arn]
  }
}

resource "aws_sns_topic_policy" "topic_policy" {
  arn    = module.hmpps-domain-events.topic_arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
