module "whereabouts_api_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "whereabouts_api_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.whereabouts_api_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "whereabouts_api_queue_policy" {
  queue_url = module.whereabouts_api_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.whereabouts_api_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.whereabouts_api_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_events.topic_arn}"
                          }
                        }
        }
      ]
  }
   EOF
}

module "whereabouts_api_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "whereabouts_api_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "whereabouts_api_queue" {
  metadata {
    name      = "whereabouts-api-sqs-instance-output"
    namespace = "whereabouts-api-prod"
  }

  data = {
    access_key_id     = module.whereabouts_api_queue.access_key_id
    secret_access_key = module.whereabouts_api_queue.secret_access_key
    sqs_wb_url        = module.whereabouts_api_queue.sqs_id
    sqs_wb_arn        = module.whereabouts_api_queue.sqs_arn
    sqs_wb_name       = module.whereabouts_api_queue.sqs_name
  }
}

resource "kubernetes_secret" "whereabouts_api_dead_letter_queue" {
  metadata {
    name      = "whereabouts-api-sqs-dl-instance-output"
    namespace = "whereabouts-api-prod"
  }

  data = {
    access_key_id     = module.whereabouts_api_dead_letter_queue.access_key_id
    secret_access_key = module.whereabouts_api_dead_letter_queue.secret_access_key
    sqs_wb_url        = module.whereabouts_api_dead_letter_queue.sqs_id
    sqs_wb_arn        = module.whereabouts_api_dead_letter_queue.sqs_arn
    sqs_wb_name       = module.whereabouts_api_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "whereabouts_api_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.whereabouts_api_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"DATA_COMPLIANCE_DELETE-OFFENDER\"]}"
}
