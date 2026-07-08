resource "aws_sns_topic_subscription" "cpr_court_cases_subscription" {
  
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.cpr-court-topic-sns-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr-court-cases-queue.sqs_arn
}

module "cpr-court-cases-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "cpr-court-cases"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cpr-court-cases-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "cpr_court_cases_sqs_queue_policy_document" {
  statement {
    sid     = "CprCourtEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.cpr-court-topic-sns-arn.value]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "cpr_court_cases_queue_policy" {
  queue_url = module.cpr-court-cases-queue.sqs_id
  policy    = data.aws_iam_policy_document.cpr_court_cases_sqs_queue_policy_document.json
}

module "cpr-court-cases-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "cpr-court-cases-dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets

resource "kubernetes_secret" "cpr-court-cases-queue-secret" {
  metadata {
    name      = "cpr-court-cases-queue-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.cpr-court-cases-queue.sqs_id
    sqs_arn  = module.cpr-court-cases-queue.sqs_arn
    sqs_name = module.cpr-court-cases-queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr-court-cases-dlq-secret" {
  metadata {
    name      = "cpr-court-cases-dlq-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.cpr-court-cases-dlq.sqs_id
    sqs_arn  = module.cpr-court-cases-dlq.sqs_arn
    sqs_name = module.cpr-court-cases-dlq.sqs_name
  }
}
