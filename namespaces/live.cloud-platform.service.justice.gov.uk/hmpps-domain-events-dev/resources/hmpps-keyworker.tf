module "keyworker_api_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "keyworker_api_queue_complexity_of_need"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.keyworker_api_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "keyworker_api_queue_policy" {
  queue_url = module.keyworker_api_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.keyworker_api_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.keyworker_api_queue.sqs_arn}",
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

module "keyworker_api_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "keyworker_api_queue_dl_complexity_of_need"
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

resource "kubernetes_secret" "keyworker_api_queue" {
  metadata {
    name      = "kw-sqs-complexity-of-need-instance-output"
    namespace = "keyworker-api-dev"
  }

  data = {
    sqs_kw_url  = module.keyworker_api_queue.sqs_id
    sqs_kw_arn  = module.keyworker_api_queue.sqs_arn
    sqs_kw_name = module.keyworker_api_queue.sqs_name
  }
}

resource "kubernetes_secret" "keyworker_api_dead_letter_queue" {
  metadata {
    name      = "kw-sqs-complexity-of-need-dl-instance-output"
    namespace = "keyworker-api-dev"
  }

  data = {
    sqs_kw_url  = module.keyworker_api_dead_letter_queue.sqs_id
    sqs_kw_arn  = module.keyworker_api_dead_letter_queue.sqs_arn
    sqs_kw_name = module.keyworker_api_dead_letter_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "keyworker_api_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.keyworker_api_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"complexity-of-need.level.changed\"]}"
}
