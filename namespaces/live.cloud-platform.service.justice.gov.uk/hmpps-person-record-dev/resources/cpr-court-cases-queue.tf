
resource "aws_sns_topic_subscription" "cpr_court-cases_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.court-cases-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr_court_cases_queue.sqs_arn
}

module "cpr_court_cases_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

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

resource "aws_sqs_queue_policy" "cpr_court_cases_queue_policy" {
  queue_url = module.cpr_court_cases_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cpr_court_cases_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cpr_court_cases_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
              {
                "aws:SourceArn": "${data.aws_ssm_parameter.court-cases-topic-arn.value}"
              }
            }
        }
      ]
  }
EOF
}

######## Dead letter queue

module "cpr_court_cases_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

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
    name = "sqs-cpr-court-case-events-secret"
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
    name = "sqs-cpr-court-case-events-dlq-secret"
    ## Name space where the listening service is found
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_court_cases_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.cpr_court_cases_dead_letter_queue.sqs_arn
    sqs_queue_name = module.cpr_court_cases_dead_letter_queue.sqs_name
  }
}
