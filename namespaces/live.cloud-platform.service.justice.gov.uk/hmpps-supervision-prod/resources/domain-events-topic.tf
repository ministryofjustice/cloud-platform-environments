data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08"
}

data "aws_ssm_parameter" "hmpps-domain-events-policy-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/sns/${data.aws_sns_topic.hmpps-domain-events.name}/irsa-policy-arn"
}

# Policy to allow SNS -> SQS
data "aws_iam_policy_document" "sqs_queue_policy_document" {
  statement {
    sid     = "DomainEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_sns_topic.hmpps-domain-events.arn]
    }
    resources = ["*"]
  }
}
