module "hmpps-delius-interventions-event-listener-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  infrastructure-support = var.infrastructure_support

  is-production    = var.is_production
  environment-name = var.environment
  namespace        = var.namespace

  sqs_name        = "hmpps-delius-interventions-event-listener-queue"
  encrypt_sqs_kms = "true"

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps-delius-interventions-event-listener-queue-policy" {
  queue_url = module.hmpps-delius-interventions-event-listener-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps-delius-interventions-event-listener-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps-delius-interventions-event-listener-queue.sqs_arn}",
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

resource "aws_sns_topic_subscription" "hmpps-delius-interventions-event-listener-queue-domain-events-subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps-delius-interventions-event-listener-queue.sqs_arn
  filter_policy = "{\"eventType\": [{\"prefix\", \"intervention.\"}]}"
}

resource "kubernetes_secret" "hmpps-delius-interventions-event-listener-queue-secret" {
  metadata {
    name      = "hmpps-delius-interventions-event-listener-queue"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps-delius-interventions-event-listener-queue.access_key_id
    secret_access_key = module.hmpps-delius-interventions-event-listener-queue.secret_access_key
    sqs_id            = module.hmpps-delius-interventions-event-listener-queue.sqs_id
    sqs_arn           = module.hmpps-delius-interventions-event-listener-queue.sqs_arn
    user_name         = module.hmpps-delius-interventions-event-listener-queue.user_name
    sqs_name          = module.hmpps-delius-interventions-event-listener-queue.sqs_name
  }
}
