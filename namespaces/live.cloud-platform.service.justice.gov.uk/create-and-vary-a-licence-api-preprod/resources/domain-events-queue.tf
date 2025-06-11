module "cvl_domain_events_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "cvl_domain_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "cvl_domain_events_queue_policy" {
  queue_url = module.cvl_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cvl_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cvl_domain_events_queue.sqs_arn}",
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

module "cvl_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name        = "cvl_domain_events_dead_letter_queue"
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

resource "kubernetes_secret" "cvl_domain_events_queue" {
  metadata {
    name      = "sqs-domain-events-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cvl_domain_events_queue.sqs_id
    sqs_queue_arn  = module.cvl_domain_events_queue.sqs_arn
    sqs_queue_name = module.cvl_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "cvl_domain_events_dead_letter_queue" {
  metadata {
    name      = "sqs-domain-events-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.cvl_domain_events_queue.sqs_id
    sqs_queue_arn  = module.cvl_domain_events_queue.sqs_arn
    sqs_queue_name = module.cvl_domain_events_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "cvl_domain_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cvl_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "person.community.manager.allocated",
    ]
  })
}
