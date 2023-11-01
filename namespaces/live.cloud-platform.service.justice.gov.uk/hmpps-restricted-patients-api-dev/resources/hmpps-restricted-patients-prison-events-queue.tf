module "restricted_patients_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "restricted_patients_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.restricted_patients_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
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

resource "aws_sqs_queue_policy" "restricted_patients_queue_policy" {
  queue_url = module.restricted_patients_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.restricted_patients_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.restricted_patients_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "restricted_patients_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "restricted_patients_queue_dl"
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

resource "kubernetes_secret" "restricted_patients_queue" {
  metadata {
    name      = "prison-events-restricted-patients-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.restricted_patients_queue.sqs_id
    sqs_queue_arn  = module.restricted_patients_queue.sqs_arn
    sqs_queue_name = module.restricted_patients_queue.sqs_name
  }
}

resource "kubernetes_secret" "restricted_patients_dead_letter_queue" {
  metadata {
    name      = "prison-events-restricted-patients-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.restricted_patients_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.restricted_patients_dead_letter_queue.sqs_arn
    sqs_queue_name = module.restricted_patients_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "restricted_patients_subscription" {
  provider      = aws.london
  topic_arn     = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol      = "sqs"
  endpoint      = module.restricted_patients_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "OFFENDER_MOVEMENT-RECEPTION"
    ]
  })
}

data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-${var.environment}/topic-arn"
}
