module "hmpps_prisoner_to_nomis_agencyregisters_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hmpps_prisoner_to_nomis_agencyregisters_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue.sqs_arn
    maxReceiveCount     = 5
  })

  # Tags
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

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_agencyregisters_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_arn}",
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

module "hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_to_nomis_agencyregisters_dlq"
  encrypt_sqs_kms = "true"


  # Tags
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

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_agencyregisters_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-agencyregisters"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-agencyregisters-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_agencyregisters_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_agencyregisters_subscription" {
  provider            = aws.london
  topic_arn           = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol            = "sqs"
  endpoint            = module.hmpps_prisoner_to_nomis_agencyregisters_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    eventType = [
      "register.court.inserted",
      "register.court.amended",
      "register.court.deleted",
      "register.court.email.inserted",
      "register.court.email.amended",
      "register.court.email.deleted",
      "register.court.address.inserted",
      "register.court.address.amended",
      "register.court.address.deleted",
      "register.court.phone.inserted",
      "register.court.phone.amended",
      "register.court.phone.deleted",
      "register.agency.inserted",
      "register.agency.amended",
      "register.agency.deleted",
      "register.agency.email.inserted",
      "register.agency.email.amended",
      "register.agency.email.deleted",
      "register.agency.address.inserted",
      "register.agency.address.amended",
      "register.agency.address.deleted",
      "register.agency.phone.inserted",
      "register.agency.phone.amended",
      "register.agency.phone.deleted",
      "register.hospital.inserted",
      "register.hospital.amended",
      "register.hospital.deleted",
      "register.hospital.address.inserted",
      "register.hospital.address.amended",
      "register.hospital.address.deleted",
      "register.hospital.phone.inserted",
      "register.hospital.phone.amended",
      "register.hospital.phone.deleted",
      "register.policecustodysuite.inserted",
      "register.policecustodysuite.amended",
      "register.policecustodysuite.deleted",
      "register.policecustodysuite.email.inserted",
      "register.policecustodysuite.email.amended",
      "register.policecustodysuite.email.deleted",
      "register.policecustodysuite.address.inserted",
      "register.policecustodysuite.address.amended",
      "register.policecustodysuite.address.deleted",
      "register.policecustodysuite.phone.inserted",
      "register.policecustodysuite.phone.amended",
      "register.policecustodysuite.phone.deleted",
      "register.probationoffice.inserted",
      "register.probationoffice.amended",
      "register.probationoffice.deleted",
      "register.probationoffice.email.inserted",
      "register.probationoffice.email.amended",
      "register.probationoffice.email.deleted",
      "register.probationoffice.address.inserted",
      "register.probationoffice.address.amended",
      "register.probationoffice.address.deleted",
      "register.probationoffice.phone.inserted",
      "register.probationoffice.phone.amended",
      "register.probationoffice.phone.deleted",
      "register.approvedpremises.inserted",
      "register.approvedpremises.amended",
      "register.approvedpremises.deleted",
      "register.approvedpremises.email.inserted",
      "register.approvedpremises.email.amended",
      "register.approvedpremises.email.deleted",
      "register.approvedpremises.address.inserted",
      "register.approvedpremises.address.amended",
      "register.approvedpremises.address.deleted",
      "register.approvedpremises.phone.inserted",
      "register.approvedpremises.phone.amended",
      "register.approvedpremises.phone.deleted"
    ]
  })
}
