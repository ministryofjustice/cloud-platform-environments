module "prisoner_from_nomis_sentencing_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "prisoner_from_nomis_sentencing_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_from_nomis_sentencing_queue_policy" {
  queue_url = module.prisoner_from_nomis_sentencing_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_from_nomis_sentencing_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_from_nomis_sentencing_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "prisoner_from_nomis_sentencing_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "prisoner_from_nomis_sentencing_dl_queue"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_sentencing_queue" {
  metadata {
    name      = "prisoner-from-nomis-sentencing-queue"
    namespace = "hmpps-prisoner-from-nomis-migration-dev"
  }

  data = {
    access_key_id     = module.prisoner_from_nomis_sentencing_queue.access_key_id
    secret_access_key = module.prisoner_from_nomis_sentencing_queue.secret_access_key
    sqs_id            = module.prisoner_from_nomis_sentencing_queue.sqs_id
    sqs_arn           = module.prisoner_from_nomis_sentencing_queue.sqs_arn
    sqs_name          = module.prisoner_from_nomis_sentencing_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_from_nomis_sentencing_dead_letter_queue" {
  metadata {
    name      = "prisoner-from-nomis-sentencing-dl-queue"
    namespace = "hmpps-prisoner-from-nomis-migration-dev"
  }

  data = {
    access_key_id     = module.prisoner_from_nomis_sentencing_dead_letter_queue.access_key_id
    secret_access_key = module.prisoner_from_nomis_sentencing_dead_letter_queue.secret_access_key
    sqs_id            = module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_id
    sqs_arn           = module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_arn
    sqs_name          = module.prisoner_from_nomis_sentencing_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "prisoner_from_nomis_sentencing_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.prisoner_from_nomis_sentencing_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"KEY_DATE_ADJUSTMENT_UPSERTED\",\"KEY_DATE_ADJUSTMENT_DELETED\",\"SENTENCE_ADJUSTMENT_UPSERTED\",\"SENTENCE_ADJUSTMENT_DELETED\"]}"
}
