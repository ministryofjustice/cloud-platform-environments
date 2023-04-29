module "application-events-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "application-events-dlq"

  encrypt_sqs_kms = true

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "application-events-dlq" {
  metadata {
    name      = "application-events-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.application-events-dlq.access_key_id
    secret_access_key = module.application-events-dlq.secret_access_key

    sqs_id   = module.application-events-dlq.sqs_id
    sqs_name = module.application-events-dlq.sqs_name
    sqs_arn  = module.application-events-dlq.sqs_arn
  }
}

resource "aws_sqs_queue_policy" "events-sns-to-application-events-dlq-policy" {
  queue_url = module.application-events-dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.application-events-dlq.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": { "Service": "sns.amazonaws.com" },
          "Resource": "${module.application-events-dlq.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition": {
            "ArnEquals": {
              "aws:SourceArn": "${module.application-events-sns-topic.topic_arn}"
            }
          }
        }
      ]
  }
  EOF
}
