data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}

module "integration_api_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "integration_api_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.integration_api_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london_default_github_tag
  }
}

module "integration_api_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "integration_api_domain_events_queue_dl"
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
    aws = aws.london_default_github_tag
  }
}

resource "aws_sqs_queue_policy" "integration_api_domain_events_queue_policy" {
  queue_url = module.integration_api_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.integration_api_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.integration_api_domain_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "integration_api_domain_events_subscription" {
  provider  = aws.london_default_github_tag
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.integration_api_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "probation-case.registration.added",
      "probation-case.registration.updated",
      "risk-assessment.scores.determined",
      "probation-case.risk-scores.ogrs.manual-calculation",
      "RISK-ASSESSMENT_SCORES_RSR_DETERMINED_RECEIVED",
      "RISK-ASSESSMENT_SCORES_OGRS_DETERMINED_RECEIVED"
    ]
  })
}

resource "kubernetes_secret" "integration_api_domain_events_queue" {
  metadata {
    name      = "hmpps-integration-api-domain-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id                        = module.integration_api_domain_events_queue.sqs_id
    sqs_arn                       = module.integration_api_domain_events_queue.sqs_arn
    sqs_name                      = module.integration_api_domain_events_queue.sqs_name
    hmpps_domain_events_topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value

  }
}

resource "kubernetes_secret" "integration_api_domain_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-integration-api-domain-events-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.integration_api_domain_events_dead_letter_queue.sqs_id
    sqs_arn  = module.integration_api_domain_events_dead_letter_queue.sqs_arn
    sqs_name = module.integration_api_domain_events_dead_letter_queue.sqs_name
  }
}