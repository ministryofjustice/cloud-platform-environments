module "education_and_work_plan_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "education_and_work_plan_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.education_and_work_plan_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "education_and_work_plan_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "education_and_work_plan_domain_events_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "education_and_work_plan_domain_events_queue_policy" {
  queue_url = module.education_and_work_plan_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.education_and_work_plan_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.education_and_work_plan_domain_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

resource "aws_sns_topic_subscription" "education_and_work_plan_domain_events_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.education_and_work_plan_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prisoner-offender-search.prisoner.released",
      "prisoner-offender-search.prisoner.received"
    ]
  })

}

resource "kubernetes_secret" "education_and_work_plan_domain_events_queue" {
  metadata {
    name      = "education-and-work-plan-domain-events-sqs-instance-output"
    namespace = "hmpps-education-and-work-plan-dev"
  }

  data = {
    sqs_queue_url  = module.education_and_work_plan_domain_events_queue.sqs_id
    sqs_queue_arn  = module.education_and_work_plan_domain_events_queue.sqs_arn
    sqs_queue_name = module.education_and_work_plan_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "education_and_work_plan_dlq" {
  metadata {
    name      = "education-and-work-plan-domain-events-sqs-dl-instance-output"
    namespace = "hmpps-education-and-work-plan-dev"
  }

  data = {
    sqs_queue_url  = module.education_and_work_plan_domain_events_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.education_and_work_plan_domain_events_dead_letter_queue.sqs_arn
    sqs_queue_name = module.education_and_work_plan_domain_events_dead_letter_queue.sqs_name
  }
}
