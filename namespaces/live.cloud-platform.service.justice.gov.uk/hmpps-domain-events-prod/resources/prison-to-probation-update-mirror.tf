# Queue to mirror data into preprod for testing
module "prison_to_probation_update_mirror_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prison_to_probation_update_mirror_hmpps_queue"
  encrypt_sqs_kms           = true
  message_retention_seconds = 1209600 # 2 weeks
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

# Policy to allow topic to push messages to the queue
data "aws_iam_policy_document" "prison_to_probation_update_mirror_queue_policy" {
  statement {
    sid     = "${module.prison_to_probation_update_mirror_queue.sqs_arn}/SQSDefaultPolicy"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [module.hmpps-domain-events.topic_arn]
    }
    resources = [module.prison_to_probation_update_mirror_queue.sqs_arn]
  }
}

resource "aws_sqs_queue_policy" "prison_to_probation_update_mirror_queue_policy" {
  queue_url = module.prison_to_probation_update_mirror_queue.sqs_id
  policy    = data.aws_iam_policy_document.prison_to_probation_update_mirror_queue_policy.json
}

# Subscription to the hmpps-domain-events topic
resource "aws_sns_topic_subscription" "prison_to_probation_update_mirror_subscription" {
  protocol      = "sqs"
  topic_arn     = module.hmpps-domain-events.topic_arn
  endpoint      = module.prison_to_probation_update_mirror_queue.sqs_arn
  provider      = aws.london
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received"
    ]
  })
}

# Kubernetes secret to allow management of the SNS subscription
resource "kubernetes_secret" "prison_to_probation_update_topic_access" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "prison-to-probation-update-prod"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}

# Kubernetes secret to allow the preprod service to read from the queue
resource "kubernetes_secret" "prison_to_probation_update_mirror_queue" {
  metadata {
    name      = "sqs-hmpps-domain-events-mirror"
    namespace = "prison-to-probation-update-preprod"
  }

  data = {
    access_key_id     = module.prison_to_probation_update_mirror_queue.access_key_id
    secret_access_key = module.prison_to_probation_update_mirror_queue.secret_access_key
    sqs_queue_url     = module.prison_to_probation_update_mirror_queue.sqs_id
    sqs_queue_arn     = module.prison_to_probation_update_mirror_queue.sqs_arn
    sqs_queue_name    = module.prison_to_probation_update_mirror_queue.sqs_name
    subscription_arn  = aws_sns_topic_subscription.prison_to_probation_update_mirror_subscription.arn
  }
}

