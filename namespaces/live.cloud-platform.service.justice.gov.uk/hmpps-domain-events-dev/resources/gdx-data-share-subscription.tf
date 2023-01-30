
module "gdx_data_share_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"

  environment-name          = var.environment-name
  team_name                 = "GDX"
  infrastructure-support    = "michael.willis@digital.justice.gov.uk"
  application               = "GDX Data Share Platform"
  sqs_name                  = "gdx_data_share_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.gdx_data_share_dlq.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "gdx_data_share_queue_policy" {
  queue_url = module.gdx_data_share_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.gdx_data_share_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.gdx_data_share_queue.sqs_arn}",
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

module "gdx_data_share_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.9.1"

  environment-name       = var.environment-name
  team_name              = "GDX"
  infrastructure-support = "michael.willis@digital.justice.gov.uk"
  application            = "GDX Data Share Platform"
  sqs_name               = "gdx_data_share_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "gdx_data_share_queue" {
  metadata {
    name = "sqs-gdx-data-share-secret"
    # injected here and then sent manually over to GDS - an external client of the consuming service
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.gdx_data_share_queue.access_key_id
    secret_access_key = module.gdx_data_share_queue.secret_access_key
    sqs_queue_url     = module.gdx_data_share_queue.sqs_id
    sqs_queue_arn     = module.gdx_data_share_queue.sqs_arn
    sqs_queue_name    = module.gdx_data_share_queue.sqs_name
  }
}

resource "kubernetes_secret" "gdx_data_share_dlq" {
  metadata {
    name = "sqs-gdx-datashare-dl-secret"
    # injected here and then sent manually over to GDS - an external client of the consuming service
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.gdx_data_share_queue.access_key_id
    secret_access_key = module.gdx_data_share_queue.secret_access_key
    sqs_queue_url     = module.gdx_data_share_queue.sqs_id
    sqs_queue_arn     = module.gdx_data_share_queue.sqs_arn
    sqs_queue_name    = module.gdx_data_share_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "gdx_data_share_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.gdx_data_share_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.received\"]}"
}


