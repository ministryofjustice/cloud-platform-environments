module "hmpps_extract_placed_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_extract_placed_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_extract_placed_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "hmpps_extract_placed_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_extract_placed_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "hmpps_extract_placed_queue_policy" {

  statement {
    sid     = "TopicToQueue"
    effect  = "Allow"
    actions = ["SQS:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.extract-placed-topic.topic_arn]
    }
    resources = [module.hmpps_extract_placed_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "hmpps_extract_placed_queue_policy" {
  queue_url = module.hmpps_extract_placed_queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps_extract_placed_queue_policy.json
}

resource "aws_sns_topic_subscription" "hmpps_extract_placed_queue_subscription" {
  provider  = aws.london
  topic_arn = module.extract-placed-topic.topic_arn
  protocol  = "sqs"
  endpoint  = module.hmpps_extract_placed_queue.sqs_arn
}

resource "kubernetes_secret" "hmpps_extract_placed_queue" {
  metadata {
    name      = "hmpps-extract-placed-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id           = module.hmpps_extract_placed_queue.access_key_id
    secret_access_key       = module.hmpps_extract_placed_queue.secret_access_key
    sqs_queue_url           = module.hmpps_extract_placed_queue.sqs_id
    sqs_queue_arn           = module.hmpps_extract_placed_queue.sqs_arn
    sqs_queue_name          = module.hmpps_extract_placed_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_extract_placed_dead_letter_queue" {
  metadata {
    name      = "hmpps-extract-placed-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id           = module.hmpps_extract_placed_dead_letter_queue.access_key_id
    secret_access_key       = module.hmpps_extract_placed_dead_letter_queue.secret_access_key
    sqs_queue_url           = module.hmpps_extract_placed_dead_letter_queue.sqs_id
    sqs_queue_arn           = module.hmpps_extract_placed_dead_letter_queue.sqs_arn
    sqs_queue_name          = module.hmpps_extract_placed_dead_letter_queue.sqs_name
  }
}


