module "prisoner_offender_search_domain_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "prisoner_offender_search_domain_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_search_domain_dlq.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_offender_search_domain_queue_policy" {
  queue_url = module.prisoner_offender_search_domain_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_offender_search_domain_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_offender_search_domain_queue.sqs_arn}",
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

module "prisoner_offender_search_domain_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "prisoner_offender_search_domain_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_offender_search_domain_queue" {
  metadata {
    name      = "sqs-domain-event-secret"
    namespace = "prisoner-offender-search-preprod"
  }

  data = {
    sqs_queue_url  = module.prisoner_offender_search_domain_queue.sqs_id
    sqs_queue_arn  = module.prisoner_offender_search_domain_queue.sqs_arn
    sqs_queue_name = module.prisoner_offender_search_domain_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_search_domain_dlq" {
  metadata {
    name      = "sqs-domain-event-dlq-secret"
    namespace = "prisoner-offender-search-preprod"
  }

  data = {
    sqs_queue_url  = module.prisoner_offender_search_domain_dlq.sqs_id
    sqs_queue_arn  = module.prisoner_offender_search_domain_dlq.sqs_arn
    sqs_queue_name = module.prisoner_offender_search_domain_dlq.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_offender_search_domain_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prisoner_offender_search_domain_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"incentives.iep-review.inserted\", \"incentives.iep-review.updated\", \"incentives.iep-review.deleted\", \"incentives.prisoner.next-review-date-changed\"]}"
}
