module "hmpps_pfs_analytics" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "hmpps-pfs-analytics"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "web_analytics_analytics_sns_client_policy" {
  policy_id = module.hmpps_pfs_analytics.topic_arn

  # Allow PFS Clients to publish messages to SNS topics
  statement {
    sid    = "AllowWebAnalyticsCommonSnsPublish"
    effect = "Allow"

    actions   = ["sns:Publish"]
    resources = [module.hmpps_pfs_analytics.topic_arn]

    principals {
      type        = "AWS"
      identifiers = local.pfs_analytics_client_arns
    }
  }
}

resource "aws_sns_topic_policy" "web_analytics_analytics_sns_client_policy" {
  arn       = module.hmpps_pfs_analytics.topic_arn
  policy    = data.aws_iam_policy_document.web_analytics_analytics_sns_client_policy.json
}
