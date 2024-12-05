module "process_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0" # use the latest release

  # Queue configuration
  sqs_name        = "process_sqs_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_redrive_allow_policy" "process_queue_redrive_allow_policy" {
  queue_url = module.process_sqs_dlq.sqs_id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [module.process_sqs.sqs_arn]
  })
}

# Should allow actions from within a service pod
resource "aws_sqs_queue_policy" "process_sqs_dlq_policy" {
  queue_url = module.process_sqs_dlq.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.process_sqs_dlq.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": "SQS:*",
          "Resource": "${module.process_sqs_dlq.sqs_arn}"
        }
      ]
  }
  EOF
}

resource "kubernetes_config_map" "process_sqs_dlq" {
  metadata {
    name      = "process-sqs-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.process_sqs_dlq.sqs_id
    sqs_arn  = module.process_sqs_dlq.sqs_arn
    sqs_name = module.process_sqs_dlq.sqs_name
  }
}

module "process_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0" # use the latest release

  # Queue configuration
  sqs_name        = "process_sqs"
  encrypt_sqs_kms = "true"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.process_sqs_dlq.sqs_arn}","maxReceiveCount": 1
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
}

resource "aws_sqs_queue_policy" "process_sqs_policy" {
  queue_url = module.process_sqs.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.process_sqs.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Action": "SQS:*",
          "Resource": "${module.process_sqs.sqs_arn}"
        }
      ]
  }
  EOF
}

resource "kubernetes_config_map" "process_sqs" {
  metadata {
    name      = "process-sqs"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.process_sqs.sqs_id
    sqs_arn  = module.process_sqs.sqs_arn
    sqs_name = module.process_sqs.sqs_name
  }
}
