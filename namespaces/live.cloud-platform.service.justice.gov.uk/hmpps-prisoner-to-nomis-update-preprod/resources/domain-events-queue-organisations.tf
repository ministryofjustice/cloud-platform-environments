module "hmpps_prisoner_to_nomis_organisations_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prisoner_to_nomis_organisations_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_organisations_dead_letter_queue.sqs_arn
    maxReceiveCount     = 4
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

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_organisations_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_organisations_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_organisations_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_organisations_queue.sqs_arn}",
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

module "hmpps_prisoner_to_nomis_organisations_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_to_nomis_organisations_dlq"
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

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_organisations_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-organisations"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_organisations_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_organisations_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_organisations_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_organisations_dead_letter_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-organisations-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_organisations_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_organisations_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_organisations_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_organisations_subscription" {
  provider            = aws.london
  topic_arn           = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol            = "sqs"
  endpoint            = module.hmpps_prisoner_to_nomis_organisations_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    eventType = [
      "organisations-api.organisation.created",
      "organisations-api.organisation.updated",
      "organisations-api.organisation.deleted",
      "organisations-api.organisation-types.updated",
      "organisations-api.organisation-address.created",
      "organisations-api.organisation-address.updated",
      "organisations-api.organisation-address.deleted",
      "organisations-api.organisation-email.created",
      "organisations-api.organisation-email.updated",
      "organisations-api.organisation-email.deleted",
      "organisations-api.organisation-web.created",
      "organisations-api.organisation-web.updated",
      "organisations-api.organisation-web.deleted",
      "organisations-api.organisation-phone.created",
      "organisations-api.organisation-phone.updated",
      "organisations-api.organisation-phone.deleted",
      "organisations-api.organisation-address-phone.created",
      "organisations-api.organisation-address-phone.updated",
      "organisations-api.organisation-address-phone.deleted",
    ]
  })
}
