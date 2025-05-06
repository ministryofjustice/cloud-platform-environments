
  
resource "aws_sns_topic_subscription" "cpr_court_cases_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.court-cases-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr_court_cases_queue.sqs_arn
}

module "cpr_court_cases_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                    = "cpr_court_cases_queue"
  encrypt_sqs_kms             = "true"
  message_retention_seconds   = 1209600
  visibility_timeout_seconds  = 120
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cpr_court_cases_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
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

data "aws_iam_policy_document" "cpr_court_cases_sqs_queue_policy_document" {
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
      values   = [data.aws_ssm_parameter.court-cases-topic-arn.value]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "cpr_court_cases_queue_policy" {
  queue_url = module.cpr_court_cases_queue.sqs_id
  policy    = data.aws_iam_policy_document.cpr_court_cases_sqs_queue_policy_document.json
}

######## Dead letter queue

module "cpr_court_cases_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                    = "cpr_court_cases_dlq"
  encrypt_sqs_kms             = "true"
  fifo_queue                  = "true"
  content_based_deduplication = "true"

  # Tags
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

########  Secrets

resource "kubernetes_secret" "cpr_court_cases_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-court-cases-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_court_cases_queue.sqs_id
    sqs_queue_arn  = module.cpr_court_cases_queue.sqs_arn
    sqs_queue_name = module.cpr_court_cases_queue.sqs_name
  }
}

resource "kubernetes_secret" "cpr_court_cases_dead_letter_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-court-cases-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_court_cases_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_court_cases_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_court_cases_dead_letter_queue.sqs_name
  }
}
