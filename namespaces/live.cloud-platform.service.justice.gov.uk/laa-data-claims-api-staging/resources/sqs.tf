
module "sqs_queue" {
  source                            = "./modules/sqs"
  queue_name                        = "claims-api-sqs-queue"
  sqs_queue_subscriber_namespaces = ["laa-data-claims-event-service-staging"]
  business_unit                     = var.business_unit
  application                       = var.application
  is_production                     = var.is_production
  team_name                         = var.team_name
  namespace                         = var.namespace
  environment                       = var.environment
  infrastructure_support            = var.infrastructure_support
  visibility_timeout_seconds        = 600
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
}