module "pf_queue_for_domain_events_pf_api" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  # Queue configuration
  sqs_name                  = "pf_queue_for_domain_events_pf_api"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.pf_queue_for_domain_events_dead_letter_queue.sqs_arn
    maxReceiveCount     = 5
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "pf_queue_for_domain_events_queue_policy_pf_api" {
  queue_url = module.pf_queue_for_domain_events_pf_api.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.pf_queue_for_domain_events_pf_api.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.pf_queue_for_domain_events_pf_api.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition": {
            "ArnEquals": {
              "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
            }
          }
        }
      ]
  }
   EOF
}

resource "aws_sqs_queue_policy" "pf_queue_for_domain_events_queue_dlq_policy_pf_api" {


  queue_url = module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {"AWS": "${module.hmpps_prisoner_finance_api_irsa.role_arn}"},
        "Resource": "${module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_arn}",
        "Action": [
          "sqs:StartMessageMoveTask",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
      }
    ]
  }
  EOF
}



module "pf_queue_for_domain_events_dead_letter_queue_pf_api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  # Queue configuration
  sqs_name        = "pf_queue_for_domain_events_dl_pf_api"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pf_queue_for_domain_events_pf_api" {
  metadata {
    name      = "domain-events-prisoner-finance-queue-pf-api"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pf_queue_for_domain_events_pf_api.sqs_id
    sqs_queue_arn  = module.pf_queue_for_domain_events_pf_api.sqs_arn
    sqs_queue_name = module.pf_queue_for_domain_events_pf_api.sqs_name
  }
}

resource "kubernetes_secret" "pf_queue_for_domain_events_dead_letter_queue_pf_api" {
  metadata {
    name      = "domain-events-prisoner-finance-dlq-pf-api"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_id
    sqs_queue_arn  = module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_arn
    sqs_queue_name = module.pf_queue_for_domain_events_dead_letter_queue_pf_api.sqs_name
  }
}

resource "aws_sns_topic_subscription" "pf_queue_for_domain_events_subscription_details_pf_api" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.pf_queue_for_domain_events.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "core-person-record.prison.record.created",
      "prison-offender-events.prisoner.merged",
      "OFFENDER-INSERTED"
    ]
  })
}
