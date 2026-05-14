module "sqs_queue" {
  source                            = "./modules/sqs"
  queue_name                        = "${var.namespace}-sqs-queue"
  sns_topic_arn                     = module.claims_events_sns_topic.topic_arn
  sqs_queue_subscriber_namespaces = ["laa-data-claims-event-service-uat"]
  business_unit                     = var.business_unit
  application                       = var.application
  is_production                     = var.is_production
  team_name                         = var.team_name
  namespace                         = var.namespace
  environment                       = var.environment
  infrastructure_support            = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sqs_queue" {
  metadata {
    name      = "sqs-claims-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.sqs_queue.sqs_id
    sqs_name = module.sqs_queue.sqs_name
    sqs_arn  = module.sqs_queue.sqs_queue_arn
  }
}

resource "aws_sqs_queue_policy" "claims_events_sns_to_sqs_policy" {
  queue_url = module.sqs_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.sqs_queue.sqs_queue_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": { "Service": "sns.amazonaws.com" },
          "Resource": "${module.sqs_queue.sqs_queue_arn}",
          "Action": "SQS:SendMessage",
          "Condition": {
            "ArnEquals": {
              "aws:SourceArn": "${module.claims_events_sns_topic.topic_arn}"
            }
          }
        }
      ]
  }
  EOF
}