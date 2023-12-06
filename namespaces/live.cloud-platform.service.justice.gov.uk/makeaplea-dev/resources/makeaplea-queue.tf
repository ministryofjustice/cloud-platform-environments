module "makeaplea_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "makeaplea_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.makeaplea_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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


resource "aws_sqs_queue_policy" "makeaplea_queue_policy" {
  queue_url = module.makeaplea_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.makeaplea_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.makeaplea_queue.sqs_arn}",
          "Action": [
            "SQS:ListQueues",
            "SQS:GetQueueAttributes",
            "SQS:SendMessage",
            "SQS:ReceiveMessage",
            "SQS:DeleteMessage"
          ]
        }
      ]
  }
   EOF
}

data "aws_iam_policy_document" "external_user_sqs_access_policy" {
  statement {
    sid = "AllowExternalUserToAccessSQS"
    actions = [
      "SQS:ListQueues",
      "SQS:GetQueueAttributes",
      "SQS:SendMessage",
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage"
    ]

    resources = [
      module.makeaplea_queue.sqs_arn,
      "${module.makeaplea_queue.sqs_arn}/*"
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "external-sqs-access-user-${var.environment}"
  path = "/system/external-sqs-access-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "external-sqs-read-write-policy"
  policy = data.aws_iam_policy_document.external_user_sqs_access_policy.json
  user   = aws_iam_user.user.name
}

module "makeaplea_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "makeaplea_queue_dl"
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

resource "kubernetes_secret" "makeaplea_queue" {
  metadata {
    name      = "makeaplea-instance-output-sqs-instance-output"
    namespace = "makeaplea-dev"
  }

  data = {
    irsa_policy_arn               = module.makeaplea_queue.irsa_policy_arn
    sqs_id                        = module.makeaplea_queue.sqs_id
    sqs_arn                       = module.makeaplea_queue.sqs_arn
    sqs_name                      = module.makeaplea_queue.sqs_name
    external_s3_access_user_arn   = aws_iam_user.user.arn
    external_s3_access_key_id     = aws_iam_access_key.user.id
    external_s3_secret_access_key = aws_iam_access_key.user.secret
  }
}


resource "kubernetes_secret" "makeaplea_dead_letter_queue" {
  metadata {
    name      = "pmakeaplea-sqs-dl-instance-output"
    namespace = "makeaplea-dev"
  }

  data = {
    irsa_policy_arn = module.makeaplea_dead_letter_queue.irsa_policy_arn
    sqs_id   = module.makeaplea_dead_letter_queue.sqs_id
    sqs_arn  = module.makeaplea_dead_letter_queue.sqs_arn
    sqs_name = module.makeaplea_dead_letter_queue.sqs_name
  }
}
