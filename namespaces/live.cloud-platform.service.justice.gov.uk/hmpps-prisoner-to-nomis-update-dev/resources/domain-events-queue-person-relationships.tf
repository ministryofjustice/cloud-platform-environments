module "hmpps_prisoner_to_nomis_personalrelationships_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prisoner_to_nomis_personalrelationships_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue.sqs_arn
    maxReceiveCount     = 5
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

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_personalrelationships_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_arn}",
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

module "hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_to_nomis_personalrelationships_dlq"
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

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_personalrelationships_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-personalrelationships"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-personalrelationships-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_personalrelationships_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_personalrelationships_subscription" {
  provider            = aws.london
  topic_arn           = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol            = "sqs"
  endpoint            = module.hmpps_prisoner_to_nomis_personalrelationships_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    eventType = [
      "contacts-api.contact.created",
      "contacts-api.contact.updated",
      "contacts-api.contact.deleted",
      "contacts-api.prisoner-contact.created",
      "contacts-api.prisoner-contact.updated",
      "contacts-api.prisoner-contact.deleted",
      "contacts-api.contact-address.created",
      "contacts-api.contact-address.updated",
      "contacts-api.contact-address.deleted",
      "contacts-api.contact-email.created",
      "contacts-api.contact-email.updated",
      "contacts-api.contact-email.deleted",
      "contacts-api.contact-phone.created",
      "contacts-api.contact-phone.updated",
      "contacts-api.contact-phone.deleted",
      "contacts-api.contact-address-phone.created",
      "contacts-api.contact-address-phone.updated",
      "contacts-api.contact-address-phone.deleted",
      "contacts-api.contact-identity.created",
      "contacts-api.contact-identity.updated",
      "contacts-api.contact-identity.deleted",
      "contacts-api.employment.created",
      "contacts-api.employment.updated",
      "contacts-api.employment.deleted",
      "contacts-api.prisoner-contact-restriction.created",
      "contacts-api.prisoner-contact-restriction.updated",
      "contacts-api.prisoner-contact-restriction.deleted",
      "contacts-api.contact-restriction.created",
      "contacts-api.contact-restriction.updated",
      "contacts-api.contact-restriction.deleted",
      "personal-relationships-api.domestic-status.created",
      "personal-relationships-api.domestic-status.deleted",
      "personal-relationships-api.number-of-children.created",
      "personal-relationships-api.number-of-children.deleted",
      "prisoner-offender-search.prisoner.received",
      "personal-relationships-api.prisoner-restriction.created",
      "personal-relationships-api.prisoner-restriction.updated",
      "personal-relationships-api.prisoner-restriction.deleted",
    ]
  })
}
