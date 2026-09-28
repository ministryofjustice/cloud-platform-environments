module "data_access_events_sns_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  topic_display_name = "data-access-events"
  encrypt_sns_kms    = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "data_access_events_sns_topic" {
  metadata {
    name      = "data-access-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_name = module.data_access_events_sns_topic.topic_name
    topic_arn  = module.data_access_events_sns_topic.topic_arn
  }
}

# Export the topic ARN so the Civil Decide namespace can subscribe its queue.
resource "aws_ssm_parameter" "data_access_events_sns_topic_arn" {
  type        = "String"
  name        = "/${var.namespace}/topic-arn"
  value       = module.data_access_events_sns_topic.topic_arn
  description = "Data Access events SNS topic ARN"

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

data "aws_iam_policy_document" "data_access_events_publisher" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [module.data_access_events_sns_topic.topic_arn]
  }
}

resource "aws_iam_policy" "data_access_events_publisher" {
  name        = "${var.namespace}-events-publisher"
  description = "Allows Data Access to publish events"
  policy      = data.aws_iam_policy_document.data_access_events_publisher.json
}

resource "aws_cloudwatch_metric_alarm" "data_access_events_sns_delivery_failures" {
  alarm_name        = "${module.data_access_events_sns_topic.topic_name}-delivery-failures"
  alarm_description = "Data Access event notifications have failed delivery; owned by ${var.team_name}"
  namespace         = "AWS/SNS"
  metric_name       = "NumberOfNotificationsFailed"

  dimensions = {
    TopicName = module.data_access_events_sns_topic.topic_name
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
}
