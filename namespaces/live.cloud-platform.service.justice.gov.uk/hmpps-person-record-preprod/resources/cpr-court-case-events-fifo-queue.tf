
resource "aws_sns_topic_subscription" "cpr_court_case_events_fifo_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.court-case-events-fifo-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cpr_court_case_events_fifo_queue.sqs_arn
}

module "cpr_court_case_events_fifo_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  # .fifo will be added to the sqs-name below
  sqs_name                   = "cpr_court_case_events_fifo_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
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

resource "aws_sqs_queue_policy" "cpr_court_case_events_fifo_queue_policy" {
  queue_url = module.cpr_court_case_events_fifo_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cpr_court_case_events_fifo_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cpr_court_case_events_fifo_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
              {
                "aws:SourceArn": "${data.aws_ssm_parameter.court-case-events-fifo-topic-arn.value}"
              }
            }
        }
      ]
  }
EOF
}

########  Secrets

resource "kubernetes_secret" "cpr_court_case_events_fifo_queue" {
  ## For metadata use - not _
  metadata {
    name = "sqs-cpr-court-case-fifo-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cpr_court_case_events_fifo_queue.sqs_id
    sqs_queue_arn  = module.cpr_court_case_events_fifo_queue.sqs_arn
    sqs_queue_name = module.cpr_court_case_events_fifo_queue.sqs_name
  }
}
