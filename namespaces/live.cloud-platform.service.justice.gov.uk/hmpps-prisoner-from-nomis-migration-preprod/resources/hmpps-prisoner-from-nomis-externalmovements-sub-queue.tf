module "prisoner_from_nomis_externalmovements_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "prisoner_from_nomis_externalmovements_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_from_nomis_externalmovements_dead_letter_queue.sqs_arn
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

resource "aws_sqs_queue_policy" "prisoner_from_nomis_externalmovements_queue_policy" {
  queue_url = module.prisoner_from_nomis_externalmovements_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_externalmovements_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_externalmovements_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": [
                              "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                            ]
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_externalmovements_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prisoner_from_nomis_externalmovements_dl_queue"
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

resource "kubernetes_secret" "prisoner_from_nomis_externalmovements_queue" {
  metadata {
    name      = "prison-events-externalmovements-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_externalmovements_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_externalmovements_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_externalmovements_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_externalmovements_dead_letter_queue" {
  metadata {
    name      = "prison-events-externalmovements-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_from_nomis_externalmovements_dead_letter_queue.sqs_id
    sqs_arn  = module.prisoner_from_nomis_externalmovements_dead_letter_queue.sqs_arn
    sqs_name = module.prisoner_from_nomis_externalmovements_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_externalmovements_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.prisoner_from_nomis_externalmovements_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "EXTERNAL_MOVEMENT-CHANGED",
      "MOVEMENT_APPLICATION-INSERTED",
      "MOVEMENT_APPLICATION-UPDATED",
      "MOVEMENT_APPLICATION-DELETED",
      "MOVEMENT_APPLICATION_MULTI-INSERTED",
      "MOVEMENT_APPLICATION_MULTI-UPDATED",
      "MOVEMENT_APPLICATION_MULTI-DELETED",
      "SCHEDULED_EXT_MOVE-INSERTED",
      "SCHEDULED_EXT_MOVE-UPDATED",
      "SCHEDULED_EXT_MOVE-DELETED"
    ]
  })
}

