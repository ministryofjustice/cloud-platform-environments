module "cfo_probation_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "cfo_probation_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cfo_probation_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

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

resource "aws_sqs_queue_policy" "cfo_probation_queue_policy" {
  queue_url = module.cfo_probation_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cfo_probation_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cfo_probation_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "cfo_probation_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cfo_probation_queue_dl"
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

resource "aws_iam_user_policy_attachment" "probation_policy" {
  policy_arn = module.cfo_probation_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "probation-dlq-policy" {
  policy_arn = module.cfo_probation_dead_letter_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "kubernetes_secret" "cfo_probation_queue" {
  metadata {
    name      = "cfo-probation-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_cfo_url  = module.cfo_probation_queue.sqs_id
    sqs_cfo_arn  = module.cfo_probation_queue.sqs_arn
    sqs_cfo_name = module.cfo_probation_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_probation_queue_credentials" {
  metadata {
    name      = "cfo-probation-sqs-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
    sqs_cfo_url       = module.cfo_probation_queue.sqs_id
    sqs_cfo_arn       = module.cfo_probation_queue.sqs_arn
    sqs_cfo_name      = module.cfo_probation_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_probation_dead_letter_queue" {
  metadata {
    name      = "cfo-probation-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_cfo_url  = module.cfo_probation_dead_letter_queue.sqs_id
    sqs_cfo_arn  = module.cfo_probation_dead_letter_queue.sqs_arn
    sqs_cfo_name = module.cfo_probation_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_probation_dead_letter_queue_credentials" {
  metadata {
    name      = "cfo-sqs-probation-dl-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
    sqs_cfo_url       = module.cfo_probation_dead_letter_queue.sqs_id
    sqs_cfo_arn       = module.cfo_probation_dead_letter_queue.sqs_arn
    sqs_cfo_name      = module.cfo_probation_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "cfo_probation_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cfo_probation_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER_CHANGED\"] }"
}
