module "mercury_submit_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "mercury_submit_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.mercury_submit_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "mercury_submit_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "mercury_submit_dl_queue"
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

resource "kubernetes_secret" "mercury_submit_queue" {
  metadata {
    name      = "mercury-submit-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.mercury_submit_queue.sqs_id
    sqs_arn  = module.mercury_submit_queue.sqs_arn
    sqs_name = module.mercury_submit_queue.sqs_name
  }
}

resource "kubernetes_secret" "mercury_submit_dead_letter_queue" {
  metadata {
    name      = "mercury-submit-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.mercury_submit_dead_letter_queue.sqs_id
    sqs_arn  = module.mercury_submit_dead_letter_queue.sqs_arn
    sqs_name = module.mercury_submit_dead_letter_queue.sqs_name
  }
}
