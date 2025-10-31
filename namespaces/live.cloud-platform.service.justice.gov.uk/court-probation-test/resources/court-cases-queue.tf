resource "aws_sns_topic_subscription" "court_cases_subscription" {
  
  provider  = aws.london
  topic_arn = module.court-cases.topic_arn
  protocol  = "sqs"
  endpoint  = module.court-cases-queue.sqs_arn
}

module "court-cases-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                    = "court-cases"
  encrypt_sqs_kms             = "true"
  message_retention_seconds   = 1209600
  visibility_timeout_seconds  = 120
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.court-cases-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "court_cases_sqs_queue_policy_document" {
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
      values   = [module.court-cases.topic_arn]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "court_cases_queue_policy" {
  queue_url = module.court-cases-queue.sqs_id
  policy = data.aws_iam_policy_document.court_cases_sqs_queue_policy_document.json
}

module "court-cases-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                    = "court-cases-dlq"
  encrypt_sqs_kms             = "true"
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

########  Secrets

resource "kubernetes_secret" "court-cases-queue-secret" {
  metadata {
    name      = "court-cases-queue-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.court-cases-queue.sqs_id
    sqs_arn  = module.court-cases-queue.sqs_arn
    sqs_name = module.court-cases-queue.sqs_name
  }
}

resource "kubernetes_secret" "court-cases-dlq-secret" {
  metadata {
    name      = "court-cases-dlq-credentials"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.court-cases-dlq.sqs_id
    sqs_arn  = module.court-cases-dlq.sqs_arn
    sqs_name = module.court-cases-dlq.sqs_name
  }
}
