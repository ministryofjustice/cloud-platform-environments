module "ims_extractor_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "ims_extractor_queue_${var.environment}"
  fifo_queue                 = false
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_extractor_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "ims_extractor_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "ims_extractor_dl_queue_${var.environment}"
  fifo_queue      = false
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

module "ims_transformer_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "ims_transformer_queue_${var.environment}"
  fifo_queue                 = false
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_transformer_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "ims_transformer_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "ims_transformer_dl_queue_${var.environment}"
  fifo_queue      = false
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

module "ims_reprocess_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "ims_reprocess_queue_${var.environment}"
  fifo_queue                 = false
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  delay_seconds              = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_reprocess_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
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

module "ims_reprocess_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "ims_reprocess_dl_queue_${var.environment}"
  fifo_queue      = false
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

resource "kubernetes_secret" "ims_extractor_queue" {
  metadata {
    name      = "ims-extractor-queue-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_extractor_queue.sqs_id
    sqs_arn  = module.ims_extractor_queue.sqs_arn
    sqs_name = module.ims_extractor_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_extractor_dead_letter_queue" {
  metadata {
    name      = "ims-extractor-dlq-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_extractor_dead_letter_queue.sqs_id
    sqs_arn  = module.ims_extractor_dead_letter_queue.sqs_arn
    sqs_name = module.ims_extractor_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_transformer_queue" {
  metadata {
    name      = "ims-transformer-queue-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_transformer_queue.sqs_id
    sqs_arn  = module.ims_transformer_queue.sqs_arn
    sqs_name = module.ims_transformer_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_transformer_dead_letter_queue" {
  metadata {
    name      = "ims-transformer-dlq-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_transformer_dead_letter_queue.sqs_id
    sqs_arn  = module.ims_transformer_dead_letter_queue.sqs_arn
    sqs_name = module.ims_transformer_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_reprocess_queue" {
  metadata {
    name      = "ims-reprocess-queue-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_reprocess_queue.sqs_id
    sqs_arn  = module.ims_reprocess_queue.sqs_arn
    sqs_name = module.ims_reprocess_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_reprocess_dead_letter_queue" {
  metadata {
    name      = "ims-reprocess-dlq-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_reprocess_dead_letter_queue.sqs_id
    sqs_arn  = module.ims_reprocess_dead_letter_queue.sqs_arn
    sqs_name = module.ims_reprocess_dead_letter_queue.sqs_name
  }
}