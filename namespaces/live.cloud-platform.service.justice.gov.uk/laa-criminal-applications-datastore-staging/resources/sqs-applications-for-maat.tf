module "crime-applications-for-maat-sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "crime-applications-for-maat"

  message_retention_seconds = 14 * 86400 # 2 weeks

  # if true, the sqs_name above must end with ".fifo", it's an API quirk
  fifo_queue = false

  encrypt_sqs_kms = true

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.crime-applications-for-maat-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "kubernetes_secret" "crime-applications-for-maat-sqs" {
  metadata {
    name      = "applications-for-maat-sqs"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime-applications-for-maat-sqs.access_key_id
    secret_access_key = module.crime-applications-for-maat-sqs.secret_access_key

    sqs_id   = module.crime-applications-for-maat-sqs.sqs_id
    sqs_name = module.crime-applications-for-maat-sqs.sqs_name
    sqs_arn  = module.crime-applications-for-maat-sqs.sqs_arn
  }
}

###
########### dead letter queue ###########
###

module "crime-applications-for-maat-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  sqs_name = "crime-applications-for-maat-dlq"

  encrypt_sqs_kms = true

  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "crime-applications-for-maat-dlq" {
  metadata {
    name      = "applications-for-maat-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime-applications-for-maat-dlq.access_key_id
    secret_access_key = module.crime-applications-for-maat-dlq.secret_access_key

    sqs_id   = module.crime-applications-for-maat-dlq.sqs_id
    sqs_name = module.crime-applications-for-maat-dlq.sqs_name
    sqs_arn  = module.crime-applications-for-maat-dlq.sqs_arn
  }
}

resource "aws_sqs_queue_policy" "events-sns-to-maat-sqs-policy" {
  queue_url = module.crime-applications-for-maat-sqs.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.crime-applications-for-maat-sqs.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.crime-applications-for-maat-sqs.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.application-events-sns-topic.topic_arn}"
                }
            }
        }
      ]
  }
  EOF
}
