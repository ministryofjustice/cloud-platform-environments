module "offender_events_ui_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "offender_events_ui_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_events_ui_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "offender_events_ui_queue_policy" {
  queue_url = module.offender_events_ui_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender_events_ui_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender_events_ui_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.offender_events.topic_arn}", "${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }
   
EOF

}

module "offender_events_ui_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "offender_events_ui_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_events_ui_queue" {
  metadata {
    name      = "oeu-sqs-instance-output"
    namespace = "offender-events-dev"
  }

  data = {
    access_key_id     = module.offender_events_ui_queue.access_key_id
    secret_access_key = module.offender_events_ui_queue.secret_access_key
    sqs_ptpu_url      = module.offender_events_ui_queue.sqs_id
    sqs_ptpu_arn      = module.offender_events_ui_queue.sqs_arn
    sqs_ptpu_name     = module.offender_events_ui_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_events_ui_dead_letter_queue" {
  metadata {
    name      = "oeu-sqs-dl-instance-output"
    namespace = "offender-events-dev"
  }

  data = {
    access_key_id     = module.offender_events_ui_dead_letter_queue.access_key_id
    secret_access_key = module.offender_events_ui_dead_letter_queue.secret_access_key
    sqs_ptpu_url      = module.offender_events_ui_dead_letter_queue.sqs_id
    sqs_ptpu_arn      = module.offender_events_ui_dead_letter_queue.sqs_arn
    sqs_ptpu_name     = module.offender_events_ui_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "ou_events_ui_prison_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.offender_events_ui_queue.sqs_arn
}

resource "aws_sns_topic_subscription" "ou_events_ui_probation_subscription" {
  provider  = aws.london
  topic_arn = module.probation_offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.offender_events_ui_queue.sqs_arn
}
