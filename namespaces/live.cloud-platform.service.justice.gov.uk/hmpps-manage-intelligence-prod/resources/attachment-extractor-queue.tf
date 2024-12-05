module "attachment_metadata_extractor_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "attachment_metadata_extractor_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.attachment_metadata_extractor_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "attachment_metadata_extractor_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "attachment_metadata_extractor_dl_queue"
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

resource "kubernetes_secret" "attachment_metadata_extractor_queue" {
  metadata {
    name      = "attachment-metadata-extractor-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.attachment_metadata_extractor_queue.sqs_id
    sqs_arn  = module.attachment_metadata_extractor_queue.sqs_arn
    sqs_name = module.attachment_metadata_extractor_queue.sqs_name
  }
}

resource "kubernetes_secret" "attachment_metadata_extractor_dead_letter_queue" {
  metadata {
    name      = "attachment-metadata-extractor-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.attachment_metadata_extractor_dead_letter_queue.sqs_id
    sqs_arn  = module.attachment_metadata_extractor_dead_letter_queue.sqs_arn
    sqs_name = module.attachment_metadata_extractor_dead_letter_queue.sqs_name
  }
}