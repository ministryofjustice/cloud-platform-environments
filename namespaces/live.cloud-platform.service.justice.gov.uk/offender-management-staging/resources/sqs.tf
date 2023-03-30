module "events_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "${var.namespace}-events-sqs"

  message_retention_seconds = 14 * 86400 # 2 weeks

  # if true, the sqs_name above must end with ".fifo", it's an API quirk
  fifo_queue = false

  encrypt_sqs_kms = true

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.events_sqs_dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sns_topic_subscription" "events_sqs_subscription" {
  topic_arn = module.events_sns_topic.topic_arn
  endpoint  = module.events_sqs.sqs_arn
  provider  = "aws.london"
  protocol  = "sqs"

  raw_message_delivery = true
}

resource "kubernetes_secret" "events_sqs" {
  for_each = local.dev_namespaces

  metadata {
    name      = "events-sqs"
    namespace = each.key
  }

  data = {
    access_key_id     = module.events_sqs.access_key_id
    secret_access_key = module.events_sqs.secret_access_key

    sqs_id   = module.events_sqs.sqs_id
    sqs_name = module.events_sqs.sqs_name
    sqs_arn  = module.events_sqs.sqs_arn
  }
}

module "events_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "${var.namespace}-events-sqs-dlq"

  encrypt_sqs_kms = true

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "events_sqs_dlq" {
  for_each = local.dev_namespaces

  metadata {
    name      = "${var.namespace}-events-sqs-dlq"
    namespace = each.key
  }

  data = {
    access_key_id     = module.events_sqs_dlq.access_key_id
    secret_access_key = module.events_sqs_dlq.secret_access_key

    sqs_id   = module.events_sqs_dlq.sqs_id
    sqs_name = module.events_sqs_dlq.sqs_name
    sqs_arn  = module.events_sqs_dlq.sqs_arn
  }
}

resource "aws_sqs_queue_policy" "allow_events_sns" {
  queue_url = module.events_sqs.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.events_sqs.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.events_sqs.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.events_sns_topic.topic_arn}"
                }
            }
        }
      ]
  }
  EOF
}
