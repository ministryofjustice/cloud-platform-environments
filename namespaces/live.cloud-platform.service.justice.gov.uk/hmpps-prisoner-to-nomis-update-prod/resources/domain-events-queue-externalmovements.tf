module "hmpps_prisoner_to_nomis_externalmovements_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prisoner_to_nomis_externalmovements_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

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

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_externalmovements_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_arn}",
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

module "hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_to_nomis_externalmovements_dlq"
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

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_externalmovements_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-externalmovements"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-externalmovements-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_externalmovements_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_externalmovements_subscription" {
  provider            = aws.london
  topic_arn           = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol            = "sqs"
  endpoint            = module.hmpps_prisoner_to_nomis_externalmovements_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    eventType = [
      "externalmovements-api.organisation.created",
      "externalmovements-api.organisation.updated",
      "externalmovements-api.organisation.deleted",
      "externalmovements-api.organisation-types.updated",
      "externalmovements-api.organisation-address.created",
      "externalmovements-api.organisation-address.updated",
      "externalmovements-api.organisation-address.deleted",
      "externalmovements-api.organisation-email.created",
      "externalmovements-api.organisation-email.updated",
      "externalmovements-api.organisation-email.deleted",
      "externalmovements-api.organisation-web.created",
      "externalmovements-api.organisation-web.updated",
      "externalmovements-api.organisation-web.deleted",
      "externalmovements-api.organisation-phone.created",
      "externalmovements-api.organisation-phone.updated",
      "externalmovements-api.organisation-phone.deleted",
      "externalmovements-api.organisation-address-phone.created",
      "externalmovements-api.organisation-address-phone.updated",
      "externalmovements-api.organisation-address-phone.deleted",
    ]
  })
}
