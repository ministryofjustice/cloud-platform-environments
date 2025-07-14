module "mandd_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name = "mandd_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.mandd_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_manage_and_deliver_domain_events_queue_policy" {
  queue_url = module.mandd_queue.sqs_id
  policy    = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.mandd_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.mandd_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF
}

module "mandd_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name = "mandd_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_subscription" "hmpps_manage_and_deliver_domain_events_subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.mandd_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "interventions.community-referral.created"
    ]
  })
}


resource "kubernetes_secret" "hmpps_manage_and_deliver_domain_events_queue_secret" {
  metadata {
    name      = "sqs-domain-events-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.mandd_queue.sqs_id
    queue_arn  = module.mandd_queue.sqs_arn
    queue_name = module.mandd_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_manage_and_deliver_domain_events_queue_secret_dlq" {
  metadata {
    name      = "sqs-domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    queue_url  = module.mandd_dlq.sqs_id
    queue_arn  = module.mandd_dlq.sqs_arn
    queue_name = module.mandd_dlq.sqs_name
  }
}