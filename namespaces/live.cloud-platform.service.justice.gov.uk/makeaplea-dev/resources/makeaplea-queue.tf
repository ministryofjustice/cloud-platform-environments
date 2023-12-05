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
    irsa_policy_arn = module.makeaplea_queue.irsa_policy_arn
    sqs_id   = module.makeaplea_queue.sqs_id
    sqs_arn  = module.makeaplea_queue.sqs_arn
    sqs_name = module.makeaplea_queue.sqs_name
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
