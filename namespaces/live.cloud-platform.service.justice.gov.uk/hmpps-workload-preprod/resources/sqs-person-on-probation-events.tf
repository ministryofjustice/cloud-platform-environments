module "hmpps_workload_person_on_probation_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_workload_person_on_probation_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_workload_person_on_probation_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_workload_person_on_probation_queue_policy" {
  queue_url = module.hmpps_workload_person_on_probation_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_workload_person_on_probation_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_workload_person_on_probation_queue.sqs_arn}",
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

module "hmpps_workload_person_on_probation_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_workload_person_on_probation_dlq"
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

resource "aws_sns_topic_subscription" "hmpps_workload_person_on_probation_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_workload_person_on_probation_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "tier.calculation.complete",
    ]
  })
}


resource "kubernetes_secret" "hmpps_workload_person_on_probation_queue_secret" {
  metadata {
    name      = "sqs-person-on-probation-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_workload_person_on_probation_queue.sqs_id
    sqs_queue_arn  = module.hmpps_workload_person_on_probation_queue.sqs_arn
    sqs_queue_name = module.hmpps_workload_person_on_probation_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_workload_person_on_probation_queue_dead_letter_queue" {
  metadata {
    name      = "sqs-person-on-probation-events-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_workload_person_on_probation_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_workload_person_on_probation_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_workload_person_on_probation_dead_letter_queue.sqs_name
  }
}
