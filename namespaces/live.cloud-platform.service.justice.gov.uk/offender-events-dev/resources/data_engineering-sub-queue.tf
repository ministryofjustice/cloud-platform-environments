module "data_engineering_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "data_engineering_hackathon"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "data_engineering_hackathon_queue_policy" {
  queue_url = module.data_engineering_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.data_engineering_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.data_engineering_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

resource "kubernetes_secret" "data_engineering_queue" {
  metadata {
    name      = "data-engineering-queue"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.data_engineering_queue.access_key_id
    secret_access_key = module.data_engineering_queue.secret_access_key
    sqs_url           = module.data_engineering_queue.sqs_id
    sqs_arn           = module.data_engineering_queue.sqs_arn
    sqs_name          = module.data_engineering_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "data_engineering_prison_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.data_engineering_queue.sqs_arn
}
