module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.namespace
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3                  = module.s3_bucket.irsa_policy_arn
    sqlserver_backup_s3 = module.sqlserver_backup_s3_bucket.irsa_policy_arn
    rds_mssql           = module.rds_mssql.irsa_policy_arn
    elasticache         = module.elasticache_redis.irsa_policy_arn

    # Single combined policy for all SQS queues + the SNS topic. Combining them
    # avoids attaching one managed policy per queue, which would approach the
    # AWS limit of managed policies per IAM role.
    sqs_sns = aws_iam_policy.sqs_sns.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
# Combined IAM policy granting the service account access to every SQS queue
# (and its dead-letter queue) defined in the *-queue.tf files, plus publish
# access to the SNS topic in sns.tf.
data "aws_iam_policy_document" "sqs_sns" {
  version = "2012-10-17"

  statement {
    sid     = "cfoCatsSqsAccess"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.dms_service_queue.sqs_arn,
      module.dms_service_dead_letter_queue.sqs_arn,
      module.document_service_queue.sqs_arn,
      module.document_service_dead_letter_queue.sqs_arn,
      module.payment_service_queue.sqs_arn,
      module.payment_service_dead_letter_queue.sqs_arn,
      module.task_service_queue.sqs_arn,
      module.task_service_dead_letter_queue.sqs_arn,
      module.telemetry_service_queue.sqs_arn,
      module.telemetry_service_dead_letter_queue.sqs_arn,
      module.risk_service_queue.sqs_arn,
      module.risk_service_dead_letter_queue.sqs_arnå
    ]
  }

  statement {
    sid    = "cfoCatsSnsPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]
    resources = [module.sns_topic.topic_arn]
  }
}

resource "aws_iam_policy" "sqs_sns" {
  name_prefix = "cfo-cats-sqs-sns-${var.environment}-"
  policy      = data.aws_iam_policy_document.sqs_sns.json
}
