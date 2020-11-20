module "probation_tiering_event_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "probation_tiering_event_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.probation_tiering_event_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "probation_tiering_event_queue_policy" {
  queue_url = module.probation_tiering_event_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.probation_tiering_event_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.probation_tiering_event_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_assessments_events.topic_arn}"
                          }
                        }
        }
      ]
  }
   
EOF

}

module "probation_tiering_event_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "probation_tiering_event_dl_queue"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "probation_tiering_event_queue" {
  metadata {
    name      = "tiering-sqs-instance-output"
    namespace = "probation-tiering-dev"
  }

  data = {
    access_key_id     = module.probation_tiering_event_queue.access_key_id
    secret_access_key = module.probation_tiering_event_queue.secret_access_key
    sqs_id            = module.probation_tiering_event_queue.sqs_id
    sqs_arn           = module.probation_tiering_event_queue.sqs_arn
    sqs_name          = module.probation_tiering_event_queue.sqs_name
  }
}

resource "kubernetes_secret" "probation_tiering_event_dead_letter_queue" {
  metadata {
    name      = "tiering-sqs-dl-instance-output"
    namespace = "probation-tiering-dev"
  }

  data = {
    access_key_id     = module.probation_tiering_event_dead_letter_queue.access_key_id
    secret_access_key = module.probation_tiering_event_dead_letter_queue.secret_access_key
    sqs_id            = module.probation_tiering_event_dead_letter_queue.sqs_id
    sqs_arn           = module.probation_tiering_event_dead_letter_queue.sqs_arn
    sqs_name          = module.probation_tiering_event_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "probation_tiering_event_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_assessments_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.probation_tiering_event_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"ASSESSMENT_COMPLETED\"]}"
}

