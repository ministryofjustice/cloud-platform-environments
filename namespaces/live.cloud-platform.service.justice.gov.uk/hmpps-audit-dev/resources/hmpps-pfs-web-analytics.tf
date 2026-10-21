# Acquire SSM parameters containing pfs-web-analytics SNS topic ARN's
locals {
  pfs_namespace = "hmpps-pfs-web-analytics-dev"

  prisoner_audit_sns_topics = [data.aws_ssm_parameter.pfs_common_sns_topic.value, data.aws_ssm_parameter.pfs_audit_sns_topic.value]
}

data "aws_ssm_parameter" "pfs_common_sns_topic" {
  name     = "/${local.pfs_namespace}/sns/common/sns-topic-arn"
}

data "aws_ssm_parameter" "pfs_audit_sns_topic" {
  name     = "/${local.pfs_namespace}/sns/audit/sns-topic-arn"
}
# Subscribe prisoner audit queue to SNS topics
resource "aws_sns_topic_subscription" "common_sns_subscription" {
  provider      = aws.london
  topic_arn     = data.aws_ssm_parameter.pfs_common_sns_topic.value
  protocol      = "sqs"
  endpoint      = module.hmpps_prisoner_audit_queue.sqs_arn
}

resource "aws_sns_topic_subscription" "audit_only_sns_subscription" {
  provider      = aws.london
  topic_arn     = data.aws_ssm_parameter.pfs_audit_sns_topic.value
  protocol      = "sqs"
  endpoint      = module.hmpps_prisoner_audit_queue.sqs_arn
}