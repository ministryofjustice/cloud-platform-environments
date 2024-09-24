resource "aws_sns_topic_subscription" "court_case_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.court-case-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.court_case_events_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = "{\"hearing\":{\"prosecutionCases\":{\"defendants\":{\"offences\":{\"judicialResults\":{\"judicialResultId\":[\"92566757-ef79-4804-bced-c63ebb0937e7\"]}}}}}}"
}

module "court_case_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0" 
  sqs_name                   = "court_case_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.court_case_events_dead_letter_queue.sqs_arn
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

resource "aws_sqs_queue_policy" "court_case_events_queue_policy" {
  queue_url = module.court_case_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.court_case_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.court_case_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
              {
                "aws:SourceArn": "${data.aws_ssm_parameter.court-case-events-topic-arn.value}"
              }
            }
        }
      ]
  }
EOF
}

######## Dead letter queue

module "court_case_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "court_case_events_dlq"
  encrypt_sqs_kms = "true"

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


resource "kubernetes_secret" "court_case_events_queue" { 
  metadata {
    name = "sqs-court-case-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.court_case_events_queue.sqs_id
    sqs_queue_arn  = module.court_case_events_queue.sqs_arn
    sqs_queue_name = module.court_case_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "court_case_events_dead_letter_queue" {  
  metadata {
    name = "sqs-court-case-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.court_case_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.court_case_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.court_case_events_dead_letter_queue.sqs_name
  }
}